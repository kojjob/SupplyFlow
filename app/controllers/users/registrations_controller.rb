class Users::RegistrationsController < Devise::RegistrationsController
  layout "auth"

  before_action :configure_sign_up_params, only: [ :create ]
  before_action :configure_account_update_params, only: [ :update ]
  before_action :check_organization_creation, only: [ :create ]

  # GET /users
  # This action is added to satisfy Pundit's policy_scope verification
  # It's not actually used in the application since Devise doesn't have an index action
  def index
    redirect_to new_user_registration_path
  end

  # GET /resource/sign_up
  def new
    # Create a new organization for the first user if none exists
    @organizations = Organization.all
    @creating_organization = params[:new_organization].present?

    build_resource
    yield resource if block_given?
    respond_with resource
  end

  # POST /resource
  def create
    build_resource(sign_up_params)

    # Handle organization creation or selection
    if params[:user][:create_organization] == "1" && params[:user][:organization_name].present?
      # Creating a new organization
      organization = Organization.new(name: params[:user][:organization_name])
      if organization.save
        resource.organization = organization
        # First user in an organization is automatically an owner
        resource.role = "owner"
      else
        # Add organization errors to the user
        organization.errors.full_messages.each do |message|
          resource.errors.add(:organization_name, message)
        end
        respond_with resource and return
      end
    elsif params[:user][:organization_id].present?
      # User selected an existing organization
      resource.organization_id = params[:user][:organization_id]
    else
      # Fallback to finding a default organization
      default_org = Organization.first
      resource.organization = default_org if default_org
    end

    # Save the resource
    if resource.save
      # Create default location for new organizations if needed
      if resource.organization && resource.organization.locations.none?
        resource.organization.locations.create(
          name: "Headquarters",
          address: "Default Address"
          # created_by_id: resource.id # Location model does not have created_by_id
        )
      end

      # Track activity
      resource.log_activity("user.created") if resource.respond_to?(:log_activity)

      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  # GET /resource/edit
  def edit
    super
  end

  # PUT /resource
  def update
    super do |resource|
      if resource.saved_change_to_attribute?(:email) ||
         resource.saved_change_to_attribute?(:name) ||
         resource.saved_change_to_attribute?(:phone_number)
        resource.log_activity("user.profile_updated") if resource.respond_to?(:log_activity)
      end
    end
  end

  # DELETE /resource
  def destroy
    super
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name, :phone_number, :organization_id, :organization_name, :role ])
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name, :phone_number, :ui_preferences ])
  end

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    dashboard_path
  end

  # The path used after sign up for inactive accounts.
  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end

  private

  def check_organization_creation
    # If the user is trying to create an organization but didn't provide a name
    if params[:user][:create_organization] == "1" && params[:user][:organization_name].blank?
      build_resource(sign_up_params)
      resource.errors.add(:organization_name, "can't be blank when creating a new organization")
      respond_with resource
    end
  end
end
