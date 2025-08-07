class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern

  # Include Pundit for authorization
  include Pundit::Authorization

  # Handle common exceptions
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  # Verify all actions are authorized
  after_action :verify_authorized, except: :index, unless: :skip_authorization?
  after_action :verify_policy_scoped, only: :index, unless: :skip_policy_scope?

  # Devise authentication - use different approach to avoid missing action errors
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, if: :public_page?

  # Set Current attributes for each request
  before_action :set_current_attributes

  # Set current tenant for multi-tenancy
  set_current_tenant_through_filter
  before_action :set_current_tenant
  after_action :clear_current_tenant

  # Track user activity
  after_action :track_user_activity, if: -> { current_user && !devise_controller? }

  # Load notifications for navbar
  before_action :load_notifications, if: :user_signed_in?

  private

  def load_notifications
    @unread_notifications_count = current_user.notifications.unread.count
    # Load a few recent notifications for the dropdown, e.g., last 5
    @recent_notifications = current_user.notifications.recent.limit(5)
  end

  def public_page?
    devise_controller? ||
    (controller_name == "pages" && [ "index", "about", "contact", "support", "offline", "swipe_test" ].include?(action_name)) ||
    (controller_name == "posts" && ["index", "show"].include?(action_name))
  end

  def set_current_attributes
    # Reset Current attributes
    Current.reset

    if current_user
      Current.user = current_user
      Current.organization = current_user.organization
    end

    Current.ip_address = request.remote_ip
    Current.user_agent = request.user_agent
    Current.request_id = request.uuid
  end

  def set_current_tenant
    # Skip for Devise controllers during registration/login
    return if devise_controller? && !current_user

    # Set the current tenant if user is authenticated
    if current_user && current_user.organization
      ActsAsTenant.current_tenant = current_user.organization
    elsif request.headers["X-Organization-ID"] && api_request?
      # For API requests, check for organization ID in headers
      organization = Organization.find_by(id: request.headers["X-Organization-ID"])
      ActsAsTenant.current_tenant = organization if organization
    else
      ActsAsTenant.current_tenant = nil
    end
  end

  def clear_current_tenant
    ActsAsTenant.current_tenant = nil
  end

  def api_request?
    request.format.json? || request.path.start_with?("/api/")
  end

  def pundit_user
    # Provide user and organization context to policies
    { user: current_user, organization: current_user&.organization }
  end

  def user_not_authorized(exception)
    policy_name = exception.policy.class.to_s.underscore
    action = exception.query.to_s.chomp("?")

    message = I18n.t("pundit.#{policy_name}.#{action}",
                     default: I18n.t("pundit.default",
                     default: "You are not authorized to perform this action."))

    respond_to do |format|
      format.html do
        flash[:alert] = message
        redirect_to(request.referrer || root_path)
      end

      format.json do
        render json: { error: message }, status: :forbidden
      end

      format.js do
        flash.now[:alert] = message
        render js: "window.showNotification('error', '#{j message}');"
      end
    end
  end

  def record_not_found(exception)
    respond_to do |format|
      format.html do
        flash[:alert] = "The resource you were looking for could not be found."
        redirect_to(request.referrer || root_path)
      end

      format.json do
        render json: { error: "Resource not found" }, status: :not_found
      end
    end
  end

  def active_storage_controller?
    # List of Active Storage controllers that should skip Pundit checks
    [
      "active_storage/blobs/redirect",
      "active_storage/blobs/proxy",
      "active_storage/representations/redirect",
      "active_storage/representations/proxy",
      "active_storage/disk" # For direct disk service
      # Add others if new ones are introduced or used, e.g., active_storage/direct_uploads
    ].include?(params[:controller])
  end

  def skip_authorization?
    devise_controller? || public_page? || active_storage_controller?
  end

  def skip_policy_scope?
    devise_controller? || public_page? || active_storage_controller?
  end

  def track_user_activity
    current_user.track_last_activity if current_user
  end
end
