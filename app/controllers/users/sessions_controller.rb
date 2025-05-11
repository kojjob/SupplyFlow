class Users::SessionsController < Devise::SessionsController
  layout "auth"

  before_action :configure_sign_in_params, only: [ :create ]
  after_action :log_successful_login, only: [ :create ]
  after_action :log_logout, only: [ :destroy ]

  # GET /users
  # This action is added to satisfy Pundit's policy_scope verification
  # It's not actually used in the application since Devise doesn't have an index action
  def index
    redirect_to new_user_session_path
  end

  # GET /resource/sign_in
  def new
    super
  end

  # POST /resource/sign_in
  def create
    # Check if the user is active
    user = User.find_by(email: params[:user][:email].downcase)

    if user && !user.active?
      flash[:alert] = "Your account has been deactivated. Please contact an administrator."
      redirect_to new_user_session_path and return
    end

    super do |resource|
      # Store last login information if login was successful
      if resource.persisted? && resource.errors.empty?
        resource.update_columns(
          last_login_at: Time.current,
          last_sign_in_ip: request.remote_ip
        )
      end
    end
  end

  # DELETE /resource/sign_out
  def destroy
    user = current_user
    super
    session[:current_organization_id] = nil
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [ :attribute ])
  end

  # The path users are redirected to after they sign in
  def after_sign_in_path_for(resource)
    stored_location_for(resource) || dashboard_path
  end

  # The path users are redirected to after they sign out
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  private

  def log_successful_login
    if user_signed_in? && current_user.respond_to?(:log_activity)
      current_user.log_activity("user.logged_in", {
        ip_address: request.remote_ip,
        user_agent: request.user_agent
      })
    end
  end

  def log_logout
    if @user && @user.respond_to?(:log_activity)
      @user.log_activity("user.logged_out", {
        ip_address: request.remote_ip,
        user_agent: request.user_agent
      })
    end
  end

  def set_user_for_logout
    @user = current_user
  end
end
