class NotificationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(recipient: user)
    end
  end

  def index?
    true # All authenticated users can see their notifications index
  end

  def show?
    user_is_recipient?
  end

  def mark_as_read?
    user_is_recipient?
  end

  def mark_all_as_read?
    true # Any user can mark all their own notifications as read
  end

  def destroy?
    user_is_recipient?
  end

  def settings?
    true # Any user can access their notification settings
  end

  def update_settings?
    true # Any user can update their notification settings
  end

  private

  def user_is_recipient?
    record.recipient == user
  end
end
