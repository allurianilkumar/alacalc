class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user, :current_user_session, :subdomain
  before_filter :set_locale
  before_filter :set_current_user

  def set_locale
    europe = %w[GB AT BE BG HR CY CZ DK EE FI FR DE GR HU IE IT LV LT LU MT NL PL PT RO SK SI ES SE NO]

    if params[:locale]
      I18n.locale = params[:locale]
    else
      if request.location.nil?
        I18n.locale = extract_locale_from_tld || I18n.default_locale
      elsif europe.include?(request.location.country_code)
        I18n.locale = :en
      elsif request.location.country_code == 'US'
        I18n.locale = :us
      else
        I18n.locale = extract_locale_from_tld || I18n.default_locale
      end
    end
  end

  # Get locale from top-level domain or return nil if such locale is not available
  # You have to put something like:
  #   127.0.0.1 application.com
  #   127.0.0.1 application.de
  #   127.0.0.1 application.co.uk
  # in your /etc/hosts file to try this out locally
  def extract_locale_from_tld
    top_level_domain = request.host.split('.').last
    if top_level_domain == 'uk'
      parsed_locale = 'en'
    elsif top_level_domain == 'com'
      parsed_locale = 'us'
    else
      parsed_locale = nil
    end
    (not parsed_locale.nil? and I18n.available_locales.include?(parsed_locale.to_sym)) ? parsed_locale  : nil
  end

  def subdomain
    domain_level = request.host.split('.')
    if domain_level.first == 'www'
      domain_level[1]
    else
      domain_level[0]
    end
  end

  def default_url_options(options={})
    {:locale => I18n.locale}
  end

  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.warn "Warning: Access Denied for user '#{current_user.try(:email)}', Action: '#{exception.action}', Subject: '#{exception.subject}', Message: '#{exception.message}'"
    redirect_to '/home', :notice => exception.message
  end  

  private

  def current_recipe
    Recipe.find(session[:recipe_id])
  rescue ActiveRecord::RecordNotFound
    recipe = Recipe.create
    session[:recipe_id] = recipe.id
    recipe
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
    @current_user.set_attr_encryption_key unless @current_user.nil?
    @current_user
  end

  def set_current_user
    # Makes the current user accessible to the model 
    User.current = current_user 
  end

end
