class Users::ConfirmationsController < Devise::ConfirmationsController
  layout "auth"

  # GET /users
  # This action is added to satisfy Pundit's policy_scope verification
  # It's not actually used in the application since Devise doesn't have an index action
  def index
    redirect_to new_user_confirmation_path
  end

  # GET /resource/confirmation/new
  def new
    super
  end

  # POST /resource/confirmation
  def create
    self.resource = resource_class.send_confirmation_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      # Log confirmation resend
      log_confirmation_sent(resource)
      respond_with({}, location: after_resending_confirmation_instructions_path_for(resource_name))
    else
      respond_with(resource)
    end
  end

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?

    if resource.errors.empty?
      # Log successful confirmation
      log_confirmation_success(resource)
      set_flash_message!(:notice, :confirmed)
      respond_with_navigational(resource) { redirect_to after_confirmation_path_for(resource_name, resource) }
    else
      respond_with_navigational(resource.errors, status: :unprocessable_entity) { render :new }
    end
  end

  protected

  # The path used after resending confirmation instructions.
  def after_resending_confirmation_instructions_path_for(resource_name)
    new_user_session_path if is_navigational_format?
  end

  # The path used after confirmation.
  def after_confirmation_path_for(resource_name, resource)
    if signed_in?(resource_name)
      dashboard_path
    else
      new_user_session_path
    end
  end

  private

  def log_confirmation_sent(resource)
    return unless resource.persisted?

    UserActivity.create(
      user: resource,
      organization: resource.organization,
      action: "user.confirmation_sent",
      ip_address: request.remote_ip,
      user_agent: request.user_agent,
      details: { email: resource.email }
    )
  end

  def log_confirmation_success(resource)
    return unless resource.persisted?

    UserActivity.create(
      user: resource,
      organization: resource.organization,
      action: "user.confirmed",
      ip_address: request.remote_ip,
      user_agent: request.user_agent,
      details: {
        email: resource.email,
        confirmed_at: resource.confirmed_at
      }
    )
  end
end
