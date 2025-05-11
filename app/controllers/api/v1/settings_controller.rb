module Api
  module V1
    class SettingsController < BaseController
      before_action :authenticate_api_user!

      # GET /api/v1/settings/organization
      def organization
        authorize current_user.organization

        render json: {
          organization: {
            id: current_user.organization.id,
            name: current_user.organization.name,
            subdomain: current_user.organization.subdomain,
            address: current_user.organization.address,
            city: current_user.organization.city,
            state: current_user.organization.state,
            country: current_user.organization.country,
            postal_code: current_user.organization.postal_code,
            phone: current_user.organization.phone,
            email: current_user.organization.email,
            website: current_user.organization.website,
            logo_url: current_user.organization.logo_url,
            created_at: current_user.organization.created_at,
            updated_at: current_user.organization.updated_at
          }
        }, status: :ok
      end

      # PATCH /api/v1/settings/organization
      def update_organization
        authorize current_user.organization

        if current_user.organization.update(organization_params)
          # Log the activity
          UserActivity.create(
            user: current_user,
            activity_type: "organization_updated",
            description: "Updated organization information",
            ip_address: request.remote_ip,
            user_agent: request.user_agent
          )

          render json: {
            message: "Organization updated successfully",
            organization: {
              id: current_user.organization.id,
              name: current_user.organization.name,
              subdomain: current_user.organization.subdomain,
              address: current_user.organization.address,
              city: current_user.organization.city,
              state: current_user.organization.state,
              country: current_user.organization.country,
              postal_code: current_user.organization.postal_code,
              phone: current_user.organization.phone,
              email: current_user.organization.email,
              website: current_user.organization.website,
              logo_url: current_user.organization.logo_url,
              created_at: current_user.organization.created_at,
              updated_at: current_user.organization.updated_at
            }
          }, status: :ok
        else
          render json: {
            error: "Failed to update organization",
            errors: current_user.organization.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/settings/users
      def users
        authorize current_user.organization, :manage_users?

        users = User.where(organization_id: current_user.organization_id)

        render json: {
          users: users.map do |user|
            {
              id: user.id,
              email: user.email,
              first_name: user.first_name,
              last_name: user.last_name,
              role: user.role,
              created_at: user.created_at,
              updated_at: user.updated_at,
              last_login_at: user.last_login_at
            }
          end
        }, status: :ok
      end

      private

      def organization_params
        params.require(:organization).permit(
          :name, :address, :city, :state, :country, :postal_code,
          :phone, :email, :website, :logo_url
        )
      end
    end
  end
end
