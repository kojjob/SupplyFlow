module Api
  module V1
    class UsersController < BaseController
      before_action :authenticate_api_user!

      # GET /api/v1/users/profile
      def profile
        render json: {
          user: {
            id: current_user.id,
            email: current_user.email,
            first_name: current_user.first_name,
            last_name: current_user.last_name,
            role: current_user.role,
            organization_id: current_user.organization_id,
            organization_name: current_user.organization&.name,
            created_at: current_user.created_at,
            updated_at: current_user.updated_at
          }
        }, status: :ok
      end

      # PATCH /api/v1/users/profile
      def update_profile
        if current_user.update(user_params)
          # Log the activity
          UserActivity.create(
            user: current_user,
            activity_type: "profile_updated",
            description: "Updated profile information",
            ip_address: request.remote_ip,
            user_agent: request.user_agent
          )

          render json: {
            message: "Profile updated successfully",
            user: {
              id: current_user.id,
              email: current_user.email,
              first_name: current_user.first_name,
              last_name: current_user.last_name,
              role: current_user.role,
              organization_id: current_user.organization_id,
              organization_name: current_user.organization&.name,
              created_at: current_user.created_at,
              updated_at: current_user.updated_at
            }
          }, status: :ok
        else
          render json: {
            error: "Failed to update profile",
            errors: current_user.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/users/activity
      def activity
        activities = current_user.user_activities.order(created_at: :desc).limit(50)

        render json: {
          activities: activities.map do |activity|
            {
              id: activity.id,
              activity_type: activity.activity_type,
              description: activity.description,
              created_at: activity.created_at
            }
          end
        }, status: :ok
      end

      private

      def user_params
        params.require(:user).permit(:first_name, :last_name, :email, :password,
                                     :password_confirmation)
      end
    end
  end
end
