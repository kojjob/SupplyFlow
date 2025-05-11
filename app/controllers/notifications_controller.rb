class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_notification, only: [:show, :mark_as_read, :destroy]

  def index
    @notifications = policy_scope(current_user.notifications)
                                .includes(:notifiable)
                                .recent
    
    # Apply filters if present
    @notifications = @notifications.unread if params[:filter] == 'unread'
    @notifications = @notifications.by_type(params[:type]) if params[:type].present?
    @notifications = @notifications.today if params[:period] == 'today'
    @notifications = @notifications.this_week if params[:period] == 'week'
    
    # Pagination
    @notifications = @notifications.page(params[:page]).per(10) if defined?(Kaminari)
    
    respond_to do |format|
      format.html
      format.json { render json: @notifications }
      format.turbo_stream
    end
  end

  def show
    @notification.mark_as_read!
    redirect_to @notification.url if @notification.url.present?
  end

  def mark_as_read
    @notification.mark_as_read!
    
    respond_to do |format|
      format.html { redirect_back(fallback_location: notifications_path, notice: 'Notification marked as read.') }
      format.turbo_stream
      format.json { render json: { status: 'success', unread_count: current_user.notifications.unread.count } }
    end
  end

  def mark_all_as_read
    current_user.notifications.unread.update_all(read_at: Time.current)
    
    respond_to do |format|
      format.html { redirect_to notifications_path, notice: 'All notifications marked as read.' }
      format.turbo_stream
      format.json { render json: { status: 'success', unread_count: 0 } }
    end
  end

  def destroy
    @notification.destroy
    
    respond_to do |format|
      format.html { redirect_to notifications_path, notice: 'Notification deleted.' }
      format.turbo_stream
      format.json { head :no_content }
    end
  end

  def settings
    @notification_preferences = current_user.notification_preferences || current_user.build_notification_preferences
  end

  def update_settings
    @notification_preferences = current_user.notification_preferences || current_user.build_notification_preferences
    
    if @notification_preferences.update(notification_preferences_params)
      redirect_to notifications_settings_path, notice: 'Notification settings updated successfully.'
    else
      render :settings
    end
  end

  private

  def set_notification
    @notification = current_user.notifications.find(params[:id])
  end

  def notification_preferences_params
    params.require(:notification_preferences).permit(
      :email_enabled, :push_enabled, :low_stock_alerts, 
      :order_alerts, :payment_alerts, :system_alerts
    )
  end
end
