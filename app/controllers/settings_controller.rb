class SettingsController < ApplicationController
  layout "settings"
  before_action :authenticate_user!

  def profile
    @user = current_user
    authorize @user, :update?

    # Get recent activity
    @recent_activities = @user.user_activities.order(created_at: :desc).limit(10)
  end

  def account
    @user = current_user
    authorize @user, :update?
  end

  def notifications
    @user = current_user
    authorize @user, :update?
  end

  def appearance
    @user = current_user
    authorize @user, :update?
  end

  def security
    @user = current_user
    authorize @user, :update?
  end

  def organization
    @organization = current_user.organization
    authorize @organization, :update?
  end

  def users
    @organization = current_user.organization
    authorize @organization, :update?
    @users = policy_scope(User).where(organization: @organization).order(created_at: :desc)
  end

  def integrations
    @organization = current_user.organization
    authorize @organization, :update?
  end

  def update_profile
    @user = current_user
    authorize @user, :update?

    if @user.update(user_profile_params)
      # Log the activity with details about what was changed
      activity_details = {}
      activity_details[:name] = @user.name if @user.saved_change_to_name?
      activity_details[:email] = @user.email if @user.saved_change_to_email?
      activity_details[:phone_number] = @user.phone_number if @user.saved_change_to_phone_number?
      activity_details[:avatar_updated] = "Yes" if params[:user][:avatar].present?

      @user.log_activity("user.profile_updated", activity_details)

      # TEST NOTIFICATION
      Notification.create(
        recipient: @user,
        actor: @user, # Or nil if no specific actor
        notifiable: @user, # The user object itself or another relevant object
        action: "profile_updated_test",
        message: "Your profile was successfully updated! (Test Notification)",
        link: settings_profile_path
      )
      # END TEST NOTIFICATION

      redirect_to settings_profile_path, notice: "Your profile has been updated successfully."
    else
      # Add error messages
      flash.now[:alert] = "There was a problem updating your profile."
      render :profile, status: :unprocessable_entity
    end
  end

  def update_account
    @user = current_user
    authorize @user, :update?

    if @user.update(user_account_params)
      @user.log_activity("user.account_updated")
      redirect_to settings_account_path, notice: "Account settings updated successfully."
    else
      render :account, status: :unprocessable_entity
    end
  end

  def update_notifications
    @user = current_user
    authorize @user, :update?

    if @user.update(notification_params)
      @user.log_activity("user.notification_preferences_updated")
      redirect_to settings_notifications_path, notice: "Notification preferences updated successfully."
    else
      render :notifications, status: :unprocessable_entity
    end
  end

  def update_appearance
    @user = current_user
    authorize @user, :update?

    if @user.update(appearance_params)
      @user.log_activity("user.appearance_settings_updated")
      redirect_to settings_appearance_path, notice: "Appearance settings updated successfully."
    else
      render :appearance, status: :unprocessable_entity
    end
  end

  def update_organization
    @organization = current_user.organization
    authorize @organization, :update?

    if @organization.update(organization_params)
      current_user.log_activity("organization.updated")
      redirect_to settings_organization_path, notice: "Organization settings updated successfully."
    else
      render :organization, status: :unprocessable_entity
    end
  end

  private

  def user_profile_params
    # Get basic profile params
    profile_params = params.require(:user).permit(:name, :phone_number, :email, :avatar, :avatar_url)

    # Handle avatar URL if provided
    if profile_params[:avatar_url].present?
      current_user.avatar_url = profile_params[:avatar_url]
      profile_params.delete(:avatar_url)
    end

    # If avatar is being uploaded, purge any existing avatar first to avoid conflicts
    if profile_params[:avatar].present? && current_user.avatar.attached?
      current_user.avatar.purge
    end

    # Return the params (avatar file upload will be handled by Active Storage)
    profile_params
  end

  def user_account_params
    params.require(:user).permit(:default_location_id, :offline_access_enabled)
  end

  def notification_params
    # Extract notification preferences from params
    notification_prefs = params.require(:user).permit(notification_preferences: {})[:notification_preferences] || {}
    { notification_preferences: notification_prefs }
  end

  def appearance_params
    # Extract UI preferences from params
    ui_prefs = params.require(:user).permit(ui_preferences: {})[:ui_preferences] || {}
    { ui_preferences: ui_prefs }
  end

  def organization_params
    params.require(:organization).permit(:name, :address, :city, :state, :postal_code, :country, :phone, :email, :website, :tax_id, :logo, settings: [ :currency ])
  end
end
