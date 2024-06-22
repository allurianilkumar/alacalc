class UsersController < ApplicationController
  # Load cancan before filter
  load_and_authorize_resource

  # GET /users/index_students
  def index_students
    @student = User.new # Emtpy student for creating new students
    @students = current_user.children
    @students = @students.tagged_with(params[:class_tag]) if params.has_key?('class_tag')
    respond_to do |format|
      format.html # index.html.haml
      format.js
    end
  end

  # GET /users/referrals
  def referrals
    if current_user.referral_code.blank?
      @info = t('users.no_referral_code')
      @referred_payments = []
    else
      @info = false
      @referred_payments = current_user.referred_payments.where(:status => 'Completed')
    end

    respond_to do |format|
      format.html # referred.html.haml
      format.js
    end
  end

  # POST /users/import_students
  def import_students
    respond_to do |format|
      if params[:file]
        @students = User.import_students(params[:file])
        format.html { render }
        return
      else
        return redirect_to index_students_users_path, :notice => 'Error while loading the spreadsheet file.' 
      end
    end
  end

  def show_student

    respond_to do |format|
      if params.has_key?('student_id')
        @student = current_user.children.find(params['student_id'])
        # Make sure that all recipes have public links
        @student.recipes.each do |r|

          # Make sure that all students recipes have a public share link
          if r.publication_secret.nil?
            r.publication_secret = SecureRandom.hex(10)
            ############## This is dangerous ! ##################
            ####### We switch user for a second to generate #####
            #### the public secrets of the student's recipes ####

            old_user = User.current
            User.current = r.user
            User.current.set_attr_encryption_key
            begin
              r.save
            ensure
              User.current.forget_attr_encryption_key
              User.current = old_user
            end

          end
        end

        format.html
      else
        format.html { redirect_to index_students_users_path, :notice => 'No student id provided.' }
      end
    end

  end

  def student_row
    @student = params[:student]
  end

  def destroy_student
    if params.has_key?('student_id')
      @student = current_user.children.find(params['student_id'])
      @student.destroy
    end

    respond_to do |format|
      format.html { redirect_to index_students_users_path }
    end
  end

  # GET /users
  def index
    @users = User.search(params[:search]).order('last_request_at desc')  # Search
    if params[:role] and params[:role].size() > 0
      @users = @users.joins(:roles).where('roles.name' => params[:role]) # Filter role
    end
    @users = @users.order('last_request_at desc')                        # Order
    @users = @users.paginate(:per_page => 50, :page => params[:page])    # Paginate

    @user_ips = User.select('current_login_ip').all.map(&:current_login_ip)
    respond_to do |format|
      format.html # index.html.haml
      format.js
    end
  end

  # GET /users/1
  def show
    @user.reload
    @complete_payments = @user.payments.where( :status => 'Completed').count
    @authentications = (['password'] + @user.authentications.find(:all, :select => 'provider').map(&:provider)).join(', ')
    respond_to do |format|
      format.html # show.html.haml
    end
  end

  # GET /users/new
  def new
    respond_to do |format|
      format.html { render :layout => 'home' }
      format.js
    end
  end

  # GET /users/new_order
  # If a user is logged in, then an order is created, using the GET parameters "c", "d" and "referral" 
  # representing the number_of_credits, subscription_period_in_days and the referral name
  # Otherwise, the user is redirected to the new_order registration form
  def new_order
    # If the URL parameters do not contain the order information, redirect back to the price plans
    if not params['c'] or not params['d']
      flash[:notice] = 'Please select a price plan.'
      redirect_to '/plans'
      return
    end
    if not params.has_key?('order')
      params['order'] = true
    end
    if not params.has_key?('referral')
      params['referral'] = ""
    end
    if current_user
      # If the user is already logged in, we redirect him straight to the payment confirmation page
      @payment = Payment.new(:number_of_credits => params['c'], :subscription_period_in_days => params['d'])
      @payment.user = current_user
      if current_user.role? :teacher
        @payment.price = Payment.price_education(@payment.subscription_period_in_days)
      else
        @payment.price = Payment.price(@payment.number_of_credits, @payment.subscription_period_in_days)
      end
      @payment.referral_user = User.find_by_referral_code params["referral"]
      if !@payment.referral_user.nil?
          @payment.discount = @payment.referral_user.referral_discount
          @payment.commission = @payment.referral_user.referral_commission
      else
          @payment.discount = 0
          @payment.commission = 0
      end
      @payment.currency = I18n.translate('number.currency.format.unit')
      @payment.status = 'Ordered'

      respond_to do |format|
        if @payment.save
          format.html { redirect_to :controller => 'payments', :action => 'basket', :id => @payment }
          format.xml  { render :xml => @payment, :status => :created, :location => @payment }
        else
          format.html { render :layout => 'home', :notice => 'Oops, something went wrong' }# new_order.html.erb
          format.xml  { render :xml => @payment.errors, :status => :unprocessable_entity }
        end
      end
    else
      # Otherwise, show the registration page
      @user = User.new
      respond_to do |format|
        format.html { render :layout => 'home' }# new_order.html.erb
        format.js
      end
    end
  end

  # GET /users/thanks
  def thanks
    respond_to do |format|
      format.html { render :layout => 'home' }# thanks.html.erb
      format.js
    end
  end

  # GET /users/1/change_password
  def change_password
    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /users/1/change_password_student
  def change_password_student
    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /users/1/edit
  def edit
    respond_to do |format|
      format.html
      format.js
    end
  end

  # POST /users/create_multiple_students
  def create_multiple_students
    ''' Creates multiples students. Errors in input data are ignored (and the student not saved). '''

    params[:students].each do |s|

      student = User.new(s)
      student.parent = current_user
      student.set_student_email()
      # The students password are automatically generated
      student.password = student.get_student_default_password()
      student.password_confirmation = student.get_student_default_password()
      if student.save_without_session_maintenance
        # Add the student role to the new user
        RolesUser.create(:role_id => Role.find_by_name('student').id, :user_id => student.id)

        # Activate the student
        student.activate!
        # Assign the student the same number of subscription days as the teacher
        student.subscription_end = current_user.subscription_end
        student.save
      end

    end

    respond_to do |format|
      format.html { redirect_to index_students_users_path, :notice => t("student.import_success") }
    end

  end

  # POST /users/create_student
  def create_student

    @student = User.new(params[:user])
    @student.parent = current_user
    @student.set_student_email()
    # The students password are automatically generated
    @student.password = @student.get_student_default_password()
    @student.password_confirmation = @student.get_student_default_password()

    respond_to do |format|
      if @student.save_without_session_maintenance
        # Add the student role to the new user
        RolesUser.create(:role_id => Role.find_by_name('student').id, :user_id => @student.id)

        # Activate the student
        @student.activate!
        # Assign the student the same number of subscription days as the teacher
        @student.subscription_end = current_user.subscription_end
        @student.save

        format.html { redirect_to index_students_users_path }

      else
        @student.email = @student.email.split('@').first
        format.html { render :action => 'new_student'}
        format.xml { render @user.errors, :status => :unprocessable_entity }

      end
    end
  end

  # POST /users
  def create
    respond_to do |format|
      if @user.save_without_session_maintenance
        if subdomain.include? configatron.education_subdomain
          # Add the teacher role to the new user
          RolesUser.create(:role_id => Role.find_by_name('Teacher').id, :user_id => @user.id)
          # Teacher accounts have by default no credits but a 7 day subscription
          @user.update_attribute('credits', 0) 
          @user.update_attribute('subscription_end', Time.now+7.days) 
        end
        if params[:user][:order]
          @user.update_attribute('credits', 0) # A new user that registered using the buy now button, does not get the free credits...
        end
        return redirect_to activate_account_path(:activation_code => @user.perishable_token, 
                                                 :order => params[:user][:order],
                                                 :c => params[:user][:c],
                                                 :d => params[:user][:d],
                                                 :referral => params[:user][:referral])
      else
        if params[:user][:order]
          format.html { render :action => 'new_order', :layout => 'home', url_options => { :controller => :user, :action => :new_order, :c => params[:c], :d => params[:d], :referral => params[:referral], :order => params[:order] } }
          format.xml
        else
          # Check if the user came from the home page. In this case we want to render the home page again
          if params[:render] == 'home'
            @page = Page.find_by_permalink('home')
            format.html { render 'pages/show', :layout => 'home' }
          # Otherwise render the users new view
          else
            format.html { render 'new', :layout => 'home' }
          end
          format.xml { render @user.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /users/1
  def update_costs
    @user = current_user
    @recipe = Recipe.find_by_id(params[:user]['recipes_attributes']['0']['id'])

    respond_to do |format|
      @user.update_attributes(params[:user])
      @recipe.reload
      if @recipe.paid? or params[:unlock]
        @ingredient_costs = @recipe.compute_cost()
      end
      format.html { render recipe_ingredient_costs_path(@recipe) }
      format.js
      format.xml
    end
  end

  # PUT /users/1
  def update_password
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to change_password_user_path(@user), :notice => 'Password updated successfully.' }
      else
        format.html { render :action => 'change_password'}
        format.xml { render @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  def update_password_student
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to controlpanels_path, :notice => 'Password updated successfully.' }
      else
        format.html { render :action => 'change_password_student'}
        format.xml { render @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  def update
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to edit_user_path(@user) }
      else
        format.html { render :action => 'edit' }
        format.xml { render @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  def update_student
    @student = current_user.children.find(params[:user][:id])
    @student.assign_attributes(params[:user])
    @student.set_student_email()

    respond_to do |format|
      if @student.save
        format.html { redirect_to show_student_users_path(:student_id => @student.id) }
      else
        format.html 
        format.xml { render @student.errors, :status => :unprocessable_entity }
      end
    end
  end

  def unsubscribe
    @user = User.new(:email => params['email'])
    render :layout => 'home'
  end

  def unsubscribe_update
    respond_to do |format|
      begin
        user = User.find_by_email(params[:user][:email])
        user.send_newsletter = false
        user.save
        format.html { redirect_to unsubscribed_users_path }
      rescue
        format.html { redirect_to unsubscribe_users_path, :notice => 'E-mail address is not known.' }
      end
    end
  end

  def unsubscribed
    render :layout => 'home'
  end

  # DELETE /users/1
  def destroy
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
    end
  end

  def activate
    @user = User.find_using_perishable_token(params[:activation_code], 3.weeks) 
    
    if @user.nil?
      redirect_to(root_path, :notice => 'The activation link does not exist or is too old. Please try logging in if your account is already active or register again.')
      return
    end

    if @user.active?
      redirect_to(root_path, :notice => 'Your account is already active.')
      return
    end

    if @user.activate!
      UserSession.create(@user, false)
      @user.send_activation_confirmation!
      if params['order']
        # The user user the price plan page, used a 'buy now' button, registered, and is now about to activate his account.
        # At this point we want to create the order and send the user to the order confirmation page.
        # We do that using the new_order ressource...
        return redirect_to new_order_users_path(params.slice(:order, :c, :d, :referral)) 
      end
      redirect_to controlpanels_url(:user => 'new')
    else
      render :action => :new
    end
  end

  # Actions for resetting the password
  def reset_password

    # Log out
    #@user_session = UserSession.find()
    #if not @user_session.nil?
    #    @user_session.destroy
    #end
    #session[:attr_password] = nil

    @user = User.find_using_perishable_token(params[:reset_password_code], 10.years)

    if @user.nil?
        flash[:notice] = "Your reset link is invalid. Please try again."
        redirect_to forgot_password_path
    else
        render :layout => "home"
    end
  end

  # Actions for resetting the password
  def reset_student_password
    @student = current_user.children.find(params[:student_id])

    @student.password = @student.get_student_default_password()
    @student.password_confirmation = @student.get_student_default_password()
    @student.save

    respond_to do |format|
      format.html { redirect_to show_student_users_path(:student_id => @student.id)}
    end
  end

  def reset_password_submit
    @user = User.find_using_perishable_token(params[:reset_password_code], 10.years) || (raise Exception)
    @user.active = true
    if @user.update_attributes(params[:user].merge({:active => true}))
      flash[:notice] = "Successfully reset password."
      redirect_to controlpanels_url
    else
      flash[:notice] = "There was a problem resetting your password."
      render :action => :reset_password
    end
  end

  def resend_activation
    if params[:login]
      @user = User.find_by_email params[:login]
      if @user && !@user.active?
        @user.send_activation_instructions!
        flash[:notice] = "Please check your e-mail for your account activation instructions!"
        redirect_to root_path
        return
      end
    end
    flash[:notice] = "Oops! Something went wrong. Try again."
    redirect_to root_path

  end

  def email_list
    @emails = User.where(:send_newsletter => true).map {|u| u.email}.join(", ")
  end

  def user_bar
    render :layout => nil
  end

end
