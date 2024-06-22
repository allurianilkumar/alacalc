class UserSessionsController < ApplicationController
  layout "home"
  # POST /user_sessions
  def create
    # Reset the session id when logging in, to prevent session fixation attacks.
    reset_session
    @user_session = UserSession.new(params[:user_session])

    respond_to do |format|
      if @user_session.save
        format.json { head :no_content } 
        format.html { 
          user = @user_session.user
          if params[:user_session][:order]
            # In that case, the user was on the price plans page, clicked on buy now and logged into the alacalc. 
            # Therefore we will create the order and redirect the user the order confirmation page
            redirect_to new_order_users_path(params[:user_session].slice(:order, :c, :d, :referral)) 
          elsif user.role? :student and
                user.valid_password? user.get_student_default_password
            # Make sure that the student has reset his password - otherwise we present the change password screen.
            redirect_to change_password_student_user_path(user)
          else
            redirect_to controlpanels_path
          end
        }
      elsif @user_session.attempted_record &&
            !@user_session.invalid_password? &&
            !@user_session.attempted_record.active?
            @resend_link = render_to_string(:partial => 'user_sessions/resend_activation_msg.erb', :locals => { :user => @user_session.attempted_record })
        format.json { render :status => :unauthorized, :json => { :errors => "Account not active" } }
        format.html { render :action => :resend_activation }
      else
        format.json { render :status => :unauthorized, :json => { :errors => @user_session.errors.full_messages } }
        @user_session.errors.full_messages.each do |msg|
          format.html { 
            if params[:user_session] and params[:user_session][:order]
              redirect_to new_order_users_path(params[:user_session].slice(:order, :c, :d, :referral)), :notice => msg 
            else
              redirect_to root_path, :notice => msg 
            end
          
          }
        end
      end
    end
  end

  # DELETE /user_sessions/1
  def destroy
    @user_session = UserSession.find()
    if not @user_session.nil?
      @user_session.destroy
    end
    session[:attr_password] = nil

    respond_to do |format|
      format.html { redirect_to(:root) }
      format.json { head :no_content }
    end
  end

  def forgot_password
    if current_user
      redirect_to change_password_user_path(current_user)
    else
        respond_to do |format|
            @user_session = UserSession.new()
            format.html
        end
    end
  end

  def forgot_password_lookup_email
    if current_user
      redirect_to edit_account_url
    else
      user = User.find_by_email(params[:user_session][:email])
      if user
        user.send_forgot_password!
        flash[:notice] = "A link to reset your password has been mailed to you."
      else
        flash[:notice] = "The email address #{params[:user_session][:email]} is not registered with a la calc. Perhaps you used a different one? Or never registered?"
        render :action => :forgot_password
      end
    end
  end


end
