class VersionsController < ApplicationController
  def revert
    @version = Version.find(params[:id])
    if @version.reify
      obj = @version.reify
      if obj.respond_to?(:attr_encryption_key)
        obj.attr_encryption_key = current_user.attr_encryption_key
      end
      obj.save!
    else
      obj=@version.item
      if obj.respond_to?(:attr_encryption_key)
        obj.attr_encryption_key = current_user.attr_encryption_key
      end
      obj.destroy
    end
    link_name = params[:redo] == "true" ? I18n.translate('nav.undo') : I18n.translate('nav.redo')
    link = view_context.link_to(link_name, revert_version_path(@version.next, :redo => !params[:redo]), :method => :post)
    redirect_to :back, :notice => I18n.translate('nav.undid') + " #{link}"
  end
end
