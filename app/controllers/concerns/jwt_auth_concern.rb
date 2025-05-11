module JwtAuthConcern
  extend ActiveSupport::Concern

  private

  def generate_jwt_token(user)
    payload = {
      user_id: user.id,
      organization_id: user.organization_id,
      role: user.role,
      type: "access",
      exp: 24.hours.from_now.to_i
    }

    JWT.encode(payload, Rails.application.credentials.secret_key_base, "HS256")
  end

  def generate_refresh_token(user)
    payload = {
      user_id: user.id,
      type: "refresh",
      exp: 30.days.from_now.to_i
    }

    JWT.encode(payload, Rails.application.credentials.secret_key_base, "HS256")
  end

  def decode_token(token, verify_expiration = true)
    JWT.decode(
      token,
      Rails.application.credentials.secret_key_base,
      true,
      { algorithm: "HS256", verify_expiration: verify_expiration }
    )
  rescue JWT::ExpiredSignature
    raise JWT::ExpiredSignature, "Token has expired"
  rescue JWT::DecodeError
    raise JWT::DecodeError, "Invalid token"
  end
end
