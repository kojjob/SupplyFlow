module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      logger.add_tags 'ActionCable', "User #{current_user.id}" if current_user
    end

    private

    def find_verified_user
      # Assumes Devise is used for authentication and warden is available
      # The key for user in warden env might be 'warden.user.user.key' or similar
      # You might need to adjust this based on your Devise setup
      if verified_user = env['warden']&.user
        verified_user
      else
        # If you're using a different auth method (e.g., token-based for APIs),
        # you'd implement that logic here.
        # For cookie-based Devise, this should generally work.
        # If no user, reject the connection.
        reject_unauthorized_connection
      end
    end
  end
end
