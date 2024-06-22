class PagesController < ApplicationController
  load_and_authorize_resource

  layout 'home'

  def index
    @pages = Page.all
  end

  def show
    # This function loads the static pages of alacalc
    # It also takes care of loading the educational specific version of 
    # pages if the requested, i.e. if on the educational subdomain:
    #
    # /home renders /edu
    # /plans renders /edu_plans
    # ...
    #
    # If the /edu_xx version of /xx does not exist, the function will fallback
    # to /xx

    if params[:permalink]
      @page = Page.find_by_permalink(params[:permalink])
      raise ActiveRecord::RecordNotFound, "Page not found" if @page.nil?
    else
      @page = Page.find(params[:id])
    end

    if @page.permalink == 'home' and not params["referral"].blank?
        @referral_user = User.find_by_referral_code params["referral"]
    end

    if subdomain.include? configatron.education_subdomain

      # Load the educational specific version if available
      if @page.permalink == 'home'
        edu_page = Page.find_by_permalink('edu')
      else
        edu_page = Page.find_by_permalink('edu_' + @page.permalink)
      end
      if not edu_page.nil?
        @page = edu_page
      end
    end

  end

  def new
    @page = Page.new
  end

  def create
    @page = Page.new(params[:page])
    if @page.save
      redirect_to @page, :notice => t('notices.created')
    else
      render :action => 'new'
    end
  end

  def edit
    @page = Page.find(params[:id])
  end

  def update
    @page = Page.find(params[:id])
    if @page.update_attributes(params[:page])
      redirect_to @page, :notice  => t('notices.updated')
    else
      render :action => 'edit'
    end
  end

  def destroy
    @page = Page.find(params[:id])
    @page.destroy
    redirect_to pages_url, :notice => t('notices.destroyed')
  end
end
