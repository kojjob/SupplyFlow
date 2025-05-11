class Users::PasswordsController < Devise::PasswordsController
  layout "auth"

  # GET /users
  # This action is added to satisfy Pundit's policy_scope verification
  # It's not actually used in the application since Devise doesn't have an index action
  def index
    redirect_to new_user_password_path
  end

  # GET /resource/password/new
  def new
    super
  end

  # POST /resource/password
  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      # Log password reset request
      log_password_reset_request(resource)
      respond_with({}, location: after_sending_reset_password_instructions_path_for(resource_name))
    else
      respond_with(resource)
    end
  end

  # GET /resource/password/edit?reset_password_token=abcdef
  def edit
    super
  end

  # PUT /resource/password
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    yield resource if block_given?

    if resource.errors.empty?
      # Log successful password reset
      log_password_reset_success(resource)
      resource.unlock_access! if unlockable?(resource)
      if Devise.sign_in_after_reset_password
        flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
        set_flash_message!(:notice, flash_message)
        resource.after_database_authentication
        sign_in(resource_name, resource)
      else
        set_flash_message!(:notice, :updated_not_active)
      end
      respond_with resource, location: after_resetting_password_path_for(resource)
    else
      set_minimum_password_length
      respond_with resource
    end
  end

  protected

  def after_resetting_password_path_for(resource)
    Devise.sign_in_after_reset_password ? dashboard_path : new_session_path(resource_name)
  end

  # The path used after sending reset password instructions
  def after_sending_reset_password_instructions_path_for(resource_name)
    new_session_path(resource_name) if is_navigational_format?
  end

  # Check if a reset_password_token is provided in the request
  def assert_reset_token_passed
    if params[:reset_password_token].blank?
      set_flash_message(:alert, :no_token)
      redirect_to new_session_path(resource_name)
    end
  end

  private

  def log_password_reset_request(resource)
    return unless resource.persisted?

    UserActivity.create(
      user: resource,
      organization: resource.organization,
      action: "user.password_reset_requested",
      ip_address: request.remote_ip,
      user_agent: request.user_agent,
      details: { request_timestamp: Time.current.to_i }
    )
  end

  def log_password_reset_success(resource)
    return unless resource.persisted?

    UserActivity.create(
      user: resource,
      organization: resource.organization,
      action: "user.password_reset_completed",
      ip_address: request.remote_ip,
      user_agent: request.user_agent,
      details: { reset_timestamp: Time.current.to_i }
    )
  end
end
