class NotificationChannel < ApplicationCable::Channel
  def subscribed
    # Ensure current_user is available from the connection
    # The ApplicationCable::Connection class should identify the user
    # and make it available as `current_user` or similar.
    if current_user
      stream_for current_user # This creates a unique stream like "notification_channel:User:1"
    else
      # Reject subscription if user is not authenticated
      reject
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    stop_all_streams
  end
end
