class OrganizationsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :create ]
  skip_after_action :verify_authorized, only: [ :create ]
  skip_after_action :verify_policy_scoped, only: [ :create ]

  def create
    # Create organization without tenant validation
    ActsAsTenant.without_tenant do
      @organization = Organization.new(organization_params)

      respond_to do |format|
        if @organization.save
          format.html { redirect_to new_user_registration_path, notice: "Organization was successfully created." }
          format.json { render json: { success: true, organization: { id: @organization.id, name: @organization.name } } }
        else
          format.html { redirect_to new_user_registration_path, alert: "Failed to create organization: #{@organization.errors.full_messages.join(', ')}" }
          format.json { render json: { success: false, errors: @organization.errors.full_messages }, status: :unprocessable_entity }
        end
      end
    end
  end

  private

  def organization_params
    params.require(:organization).permit(:name, :email, :phone, :country)
  end
end
