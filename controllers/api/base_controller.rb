module API
    class BaseController < ApplicationController
        def current_ability
              @current_ability ||= APIAbility.new(current_user)
        end

        rescue_from CanCan::AccessDenied do |exception|
            respond_to do |format|
             format.json { render :json => [], :status => :unauthorized }
            end
        end
    end
end
