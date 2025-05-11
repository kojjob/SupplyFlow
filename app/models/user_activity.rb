class UserActivity < ApplicationRecord
  # Multi-tenancy
  belongs_to :organization
  acts_as_tenant :organization

  # Associations
  belongs_to :user

  # Validations
  validates :action, presence: true

  # Scopes
  scope :recent, -> { order(created_at: :desc).limit(100) }
  scope :login_events, -> { where(action: %w[user.login user.logout user.failed_login]) }
  scope :security_events, -> { where("action LIKE ?", "user.%") }

  # Class methods
  def self.log(user, action, details = {}, request = nil)
    create(
      user: user,
      organization: user.organization,
      action: action,
      details: details,
      ip_address: request&.remote_ip,
      user_agent: request&.user_agent
    )
  end
end
