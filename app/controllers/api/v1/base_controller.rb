module Api
  module V1
    class BaseController < Api::BaseController
      # Return responses in JSON format
      respond_to :json

      # Set up Pundit authorization
      after_action :verify_authorized, except: :index, unless: :skip_authorization?
      after_action :verify_policy_scoped, only: :index, unless: :skip_policy_scope?

      # Handle Pundit authorization errors
      rescue_from Pundit::NotAuthorizedError, with: :permission_denied

      private

      def permission_denied
        error_message = "You don't have permission to perform this action."
        render json: { error: error_message }, status: :forbidden
      end

      def skip_authorization?
        false
      end

      def skip_policy_scope?
        false
      end

      def api_response(data, status = :ok, pagination = nil)
        response = { data: data }

        if pagination.present?
          response[:pagination] = {
            current_page: pagination.current_page,
            total_pages: pagination.total_pages,
            total_count: pagination.total_count,
            per_page: pagination.limit_value
          }
        end

        render json: response, status: status
      end

      def api_error(error_message, status = :unprocessable_entity)
        render json: { error: error_message }, status: status
      end

      def paginate(collection)
        page = params[:page] || 1
        per_page = params[:per_page] || 25
        collection.page(page).per(per_page)
      end
    end
  end
end
