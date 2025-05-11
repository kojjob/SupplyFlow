module Api
  module V1
    class AuthController < Api::V1::BaseController
      include JwtAuthConcern
      skip_before_action :authenticate_api_user!, only: [ :token ]
      skip_after_action :verify_authorized, only: [ :token, :refresh, :verify ]

      # POST /api/v1/auth/token
      # Authenticate user and return JWT token
      def token
        # Check if parameters are present
        unless params[:email].present? && params[:password].present?
          return api_error("Email and password are required", :unprocessable_entity)
        end

        # Find user
        @user = User.find_by(email: params[:email].downcase)

        # Check if user exists and is active
        if @user.nil?
          return api_error("Invalid email or password", :unauthorized)
        end

        # Check if user is active
        unless @user.active?
          return api_error("Your account has been deactivated", :forbidden)
        end

        # Check if password is valid
        unless @user.valid_password?(params[:password])
          # Log failed login attempt
          UserActivity.create(
            user: @user,
            organization_id: @user.organization_id,
            action: "user.login_failed",
            ip_address: request.remote_ip,
            user_agent: request.user_agent,
            details: { reason: "Invalid password" }
          )

          return api_error("Invalid email or password", :unauthorized)
        end

        # Generate JWT token
        token = generate_jwt_token(@user)
        refresh_token = generate_refresh_token(@user)

        # Update last login information
        @user.update_columns(
          last_login_at: Time.current,
          last_sign_in_ip: request.remote_ip
        )

        # Log successful login
        UserActivity.create(
          user: @user,
          organization_id: @user.organization_id,
          action: "user.logged_in",
          ip_address: request.remote_ip,
          user_agent: request.user_agent,
          details: { method: "api" }
        )

        api_response({
          token: token,
          refresh_token: refresh_token,
          expires_in: 24.hours.to_i,
          token_type: "Bearer",
          user: {
            id: @user.id,
            name: @user.name,
            email: @user.email,
            role: @user.role,
            organization: {
              id: @user.organization_id,
              name: @user.organization.name
            }
          }
        })
      end

      # GET /api/v1/auth/verify
      # Verify JWT token validity
      def verify
        api_response({
          valid: true,
          user: {
            id: current_user.id,
            name: current_user.name,
            email: current_user.email,
            role: current_user.role,
            organization: {
              id: current_user.organization_id,
              name: current_user.organization.name
            }
          }
        })
      end

      # POST /api/v1/auth/refresh
      # Refresh JWT token using refresh token
      def refresh
        # Check if refresh token is provided
        unless params[:refresh_token].present?
          return api_error("Refresh token is required", :unprocessable_entity)
        end

        begin
          # Decode refresh token
          decoded_token = JWT.decode(
            params[:refresh_token],
            Rails.application.credentials.secret_key_base,
            true,
            { algorithm: "HS256" }
          )

          # Get user ID from token
          user_id = decoded_token[0]["user_id"]
          token_type = decoded_token[0]["type"]

          # Verify token type
          unless token_type == "refresh"
            return api_error("Invalid token type", :unauthorized)
          end

          # Find user
          @user = User.find_by(id: user_id)

          # Check if user exists and is active
          if @user.nil? || !@user.active?
            return api_error("Invalid or inactive user", :unauthorized)
          end

          # Generate new tokens
          token = generate_jwt_token(@user)
          refresh_token = generate_refresh_token(@user)

          api_response({
            token: token,
            refresh_token: refresh_token,
            expires_in: 24.hours.to_i,
            token_type: "Bearer",
            user: {
              id: @user.id,
              name: @user.name,
              email: @user.email,
              role: @user.role,
              organization: {
                id: @user.organization_id,
                name: @user.organization.name
              }
            }
          })
        rescue JWT::ExpiredSignature
          api_error("Refresh token has expired", :unauthorized)
        rescue JWT::DecodeError
          api_error("Invalid refresh token", :unauthorized)
        rescue => e
          api_error("Token refresh failed: #{e.message}", :unauthorized)
        end
      end

      private
    end
  end
end
