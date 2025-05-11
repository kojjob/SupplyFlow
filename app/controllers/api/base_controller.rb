module Api
  class BaseController < ApplicationController
    include JwtAuthConcern
    # API controllers don't use CSRF protection
    skip_forgery_protection

    # Use token authentication for API requests
    skip_before_action :authenticate_user!

    # Return responses as JSON
    respond_to :json

    # Skip session creation for API
    before_action :skip_session

    # Set tenant from JWT token
    before_action :set_tenant_from_api_user

    # Handle common errors
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
    rescue_from ActionController::ParameterMissing, with: :bad_request

    protected

    def authenticate_api_user!
      unless current_api_user
        render json: { error: "Unauthorized access" }, status: :unauthorized
      end
    end

    def current_api_user
      @current_api_user ||= begin
        auth_header = request.headers["Authorization"]
        if auth_header && auth_header.start_with?("Bearer ")
          token = auth_header.split(" ").last
          payload = decode_token(token)[0]
          User.find_by(id: payload["user_id"])
        end
      rescue JWT::DecodeError, JWT::ExpiredSignature
        nil
      end
    end

    def current_user
      current_api_user
    end

    private

    def skip_session
      request.session_options[:skip] = true
    end

    def set_tenant_from_api_user
      if current_api_user
        ActsAsTenant.current_tenant = current_api_user.organization
        Current.user = current_api_user
        Current.organization = current_api_user.organization
      end
    end

    # Error responses
    def render_unauthorized(message = "Unauthorized")
      render json: { error: message }, status: :unauthorized
    end

    def not_found(exception)
      render json: { error: exception.message || "Resource not found" }, status: :not_found
    end

    def unprocessable_entity(exception)
      render json: {
        error: "Validation failed",
        details: exception.record.errors.full_messages
      }, status: :unprocessable_entity
    end

    def bad_request(exception)
      render json: { error: exception.message }, status: :bad_request
    end
  end
end
