class NotificationsController < ApplicationController
  # Load cancan before filter
  load_and_authorize_resource

  # GET /notifications
  # GET /notifications.json
  def index
    if params[:tag]
      @messages = Notification.tagged_with(params[:tag]).where('updated_at >= :date', date: '2014-01-01')
    else
      # filter old style notifications
      @messages = Notification.where('updated_at >= :date', date: '2014-01-01')
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @notifications }
    end
  end

  # GET /notifications/1
  # GET /notifications/1.json
  def show
    @notification = Notification.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @notification }
    end
  end

  # GET /notifications/new
  # GET /notifications/new.json
  def new
    @notification = Notification.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @notification }
    end
  end

  # GET /notifications/1/edit
  def edit
  end

  # POST /notifications
  # POST /notifications.json
  def create
      @notification = Notification.new(params[:notification])

      if not @notification.save
        respond_to do |format|
          format.html { render action: 'new' }
          format.json { render json: @notification.errors, status: :unprocessable_entity }
        end
        return
      end

    respond_to do |format|
      format.html { redirect_to notifications_path, notice: 'Notification was successfully created.' }
    end
  end

  # PUT /notifications/1
  # PUT /notifications/1.json
  def update
    @notification = Notification.find(params[:id])
    # Check if the user provided a valid email address
    respond_to do |format|
      if @notification.update_attributes(params[:notification])
        format.html { redirect_to notifications_path, notice: 'Notification was successfully updated.' }
        format.json { head :ok }
      else
        @notification.user_id = user_id
        format.html { render action: 'edit' }
        format.json { render json: @notification.errors, status: :unprocessable_entity }
      end
    end
  end

  def tag_up
    @notification.tag_list.add("#{current_user.email}")
    @notification.save
    @notification.reload
    redirect_to notifications_path
  end

  def tag_down
    @notification.tag_list.remove("#{current_user.email}")
    @notification.save
    @notification.reload
    redirect_to notifications_path
  end

  def follow_button
    @message = Notification.find_by_id(params[:message])
  end

  def edit_multiple
    @notifications = Notification.find(params[:notification_ids])
  end

  def update_multiple
    @notifications = Notification.find(params[:notification_ids])
    @notifications.each do |notification|
      notification.update_attributes!(params[:notification].reject { |k,v| v.blank? })
    end
    redirect_to notifications_path
  end

  # DELETE /notifications/1
  # DELETE /notifications/1.json
  def destroy_mine
    @current_user.notifications.each do |notification|
      notification.destroy
    end

    respond_to do |format|
      format.html { head :ok }
      format.json { head :ok }
    end
  end

  # DELETE /notifications/1
  # DELETE /notifications/1.json
  def destroy
    @notification = Notification.find(params[:id])
    @notification.destroy

    respond_to do |format|
      format.html { redirect_to(:back) }
      format.json { head :ok }
    end
  end
end
