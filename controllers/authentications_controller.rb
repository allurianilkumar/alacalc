class AuthenticationsController < ApplicationController
  def create
    omniauth = request.env['omniauth.auth']
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])

    if authentication
      # User is already registered with application
      sign_in_and_redirect(authentication.user)
    elsif current_user
      # User is already signed 
      flash[:notice] = 'You are already signed in. Sign out before registering.'
      session[:omniauth] = omniauth.except('extra')
      redirect_to root_path
    else
      user = User.find_by_email(omniauth['info']['email'])
      if user.nil? 
        # User is new to this application
        user = User.new
        user.apply_omniauth(omniauth)
      end
      user.authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])

      if user.save
        flash[:notice] = 'Signed in successfully.'
	user.activate!
        sign_in_and_redirect(user)
      else
        logger.error "Omniauth authentication failed. Error: " + user.errors.messages.to_s 
        logger.error "The email address is " + omniauth['info']['email'].to_s 
        logger.error "The authentication provide is " + omniauth['provider'].to_s
        logger.error "The authentication uid is " + omniauth['uid'].to_s
        flash[:notice] = 'An error occurred. Please try to sign up with your email.'
        session[:omniauth] = omniauth.except('extra')
        redirect_to root_path
      end
    end
  end

  def destroy
    @authentication = current_user.authentications.find(params[:id])
    @authentication.destroy
    flash[:notice] = 'Successfully destroyed authentication.'
    redirect_to authentications_url
  end

  private
  def sign_in_and_redirect(user)
    unless current_user
      user_session = UserSession.new(User.find_by_single_access_token(user.single_access_token))
      user_session.save
    end
    redirect_to controlpanels_path
  end
end

