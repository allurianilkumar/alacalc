class PaymentsController < ApplicationController
  load_and_authorize_resource

#  protect_from_forgery :except => [:create]

  def index
    @payments = Payment.find(:all, :conditions => { :user_id => current_user.id, :status => 'Completed' })

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @payments }
    end
  end

  # GET /payments/all
  def all

    if params[:status]
      @payments = Payment.order('created_at desc').where(:status => params[:status]).paginate(:per_page => 50, :page => params[:page])
    else
      @payments = Payment.order('created_at desc').where(:status => 'Completed').paginate(:per_page => 50, :page => params[:page])
    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    @payment = Payment.new(params[:payment])
    @payment.user = current_user

    if current_user.role? :teacher
      @payment.price = Payment.price_education(@payment.subscription_period_in_days)
    else
      @payment.price = Payment.price(@payment.number_of_credits, @payment.subscription_period_in_days)
    end

    if not params[:payment][:referral].blank?
        @payment.referral_user = User.find_by_referral_code params[:payment][:referral]
    end

    if @payment.referral_user.nil?
        @payment.discount = 0
        @payment.commission = 0
    else
        @payment.discount = @payment.referral_user.referral_discount
        @payment.commission = @payment.referral_user.referral_commission
    end

    @payment.currency = I18n.translate('number.currency.format.unit') 
    @payment.status = "Ordered"

    respond_to do |format|
      if @payment.save
        format.html { redirect_to :action => 'basket', :id => @payment }
        format.xml  { render :xml => @payment, :status => :created, :location => @payment }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @payment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # This action is called by Paypal as soon as the transaction was performed
  def payment_notification
    if params[:secret] == configatron.paypal_secret &&
       params[:receiver_email] == configatron.paypal_email # &&
       #params[:mc_gross] == cart.total_price.to_s && params[:mc_currency] == "USD"

      payment = Payment.find(params[:invoice].to_i - configatron.invoice_id_shift) # Undo the invoice id shift to obtain the db id
      payment.params = params
      payment.status =  params[:payment_status]
      payment.transaction_id = params[:txn_id]
      payment.save!
    else
      Rails.logger.warn "payment_notification was called with the wrong parameters. This might be an attempt to break the payment system?"
    end
    render :nothing => true
  end

  # GET /recipes/1
  def show
  end

  # action for 'basket' page
  def basket
  end

  # action for PDF output
  def invoice
    render :layout => "pdf"
  end

  # PUT 
  def update_notes

    @payment.notes = params["payment"]["notes"]
    if not params["payment"]["referral"].blank?
        @payment.referral_user = User.find_by_referral_code params["payment"]["referral"]
    end

    if not @payment.referral_user.nil?
        @payment.discount = @payment.referral_user.referral_discount
        @payment.commission = @payment.referral_user.referral_commission
    else
        @payment.discount = 0
        @payment.commission = 0
    end

    @payment.save
    if not params["payment"]["referral"].blank? and @payment.referral_user.nil?
        @payment.errors.add(:referral, "Referral code not valid")
    end

    respond_to do |format|
      if @payment.errors.count == 0
        format.html { render :action => 'basket', :id => @payment }
      else
        format.html { render :action => 'basket' }
        format.js { render :action => 'basket' }
        format.xml { render :xml => @payment.errors, :status => :unprocessable_entity }
      end
    end
  end
end
