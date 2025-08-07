class User < ApplicationRecord
  # Include default devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Virtual attribute for organization name in forms
  attr_accessor :organization_name
  # Disable these modules temporarily for development
  # :confirmable, :lockable, :timeoutable, :trackable

  # Multi-tenancy
  belongs_to :organization, optional: true
  # Optional tenant relationship for users - we need this to allow users to register without a tenant
  # Users will be scoped through the organization association when appropriate

  # Make sure organization is present after creation - disabled temporarily
  # validates :organization_id, presence: true, on: :create



  # Associations
  has_one_attached :avatar
  belongs_to :default_location, class_name: "Location", optional: true
  belongs_to :created_by, class_name: "User", optional: true
  has_many :created_users, class_name: "User", foreign_key: "created_by_id", dependent: :nullify
  has_many :user_activities, dependent: :destroy

  # Order associations
  has_many :purchase_orders
  has_many :sales_orders
  has_many :payments
  has_many :notifications, foreign_key: "recipient_id", dependent: :destroy, inverse_of: :recipient
  has_many :posts, foreign_key: "user_id", dependent: :destroy # Posts authored by the user
  has_many :reviews, foreign_key: "user_id", dependent: :destroy # Reviews written by the user

  # Validations
  validates :name, presence: true
  # Disable this constraint for now
  # validates :email, presence: true, uniqueness: { scope: :organization_id }
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :role, inclusion: { in: %w[owner admin manager staff viewer] }, allow_nil: true

  # Callbacks
  before_validation :set_default_role, on: :create
  # Disable temporarily
  # after_create :track_activity_create
  # after_update :track_activity_update

  # Scopes
  scope :active, -> { where(active: true) }
  scope :admins, -> { where(role: %w[owner admin]) }
  scope :staff, -> { where(role: %w[manager staff]) }

  # Role methods
  def owner?
    role == "owner"
  end

  def admin?
    role == "admin" || owner?
  end

  def manager?
    role == "manager" || admin?
  end

  def staff?
    role == "staff" || manager?
  end

  def viewer?
    role == "viewer"
  end

  # Functional role methods - based on permissions or specific roles
  def sales?
    admin? || manager? || has_permission?(:sales)
  end

  def finance?
    admin? || has_permission?(:finance)
  end

  def warehouse?
    admin? || manager? || has_permission?(:warehouse)
  end

  # Permission methods
  def can_manage_users?
    admin?
  end

  def can_manage_inventory?
    admin? || manager?
  end

  def can_view_reports?
    !viewer?
  end

  def can_adjust_stock?
    admin? || manager?
  end

  def can_transfer_stock?
    admin? || manager? || staff?
  end

  def can_create_products?
    admin? || manager?
  end

  def can_edit_products?
    admin? || manager?
  end

  def can_delete_products?
    admin?
  end

  # Generic permission check
  def has_permission?(permission)
    # Admin and owner have all permissions
    return true if admin? || owner?

    # Check specific permissions array if present
    permissions&.include?(permission.to_s)
  end

  # Activity tracking
  def log_activity(action, details = {})
    user_activities.create(
      action: action,
      details: details,
      ip_address: Current.ip_address,
      user_agent: Current.user_agent
    )
  end

  def track_last_activity
    update_column(:last_activity_at, Time.current)
  end

  # Offline support
  def has_offline_data?
    last_sync_at.present?
  end

  def needs_sync?
    last_sync_at.nil? || last_sync_at < 1.day.ago
  end

  def register_device(token)
    tokens = device_tokens
    tokens << token unless tokens.include?(token)
    update(device_tokens: tokens)
  end

  def unregister_device(token)
    update(device_tokens: device_tokens - [ token ])
  end

  # UI preferences
  def theme
    ui_preferences&.dig("theme") || "light"
  end

  def theme=(value)
    # Ensure ui_preferences is initialized
    self.ui_preferences ||= {}
    self.ui_preferences = ui_preferences.merge("theme" => value)
  end

  def locale
    ui_preferences&.dig("locale") || "en"
  end

  def locale=(value)
    # Ensure ui_preferences is initialized
    self.ui_preferences ||= {}
    self.ui_preferences = ui_preferences.merge("locale" => value)
  end

  # Avatar handling
  # Get avatar URL - prioritize Active Storage, fall back to URL in preferences
  def avatar_url
    if avatar.attached?
      # Use Active Storage
      # For Rails 7+, we can use the signed_id approach which is more reliable
      Rails.application.routes.url_helpers.rails_blob_path(avatar, only_path: true)
    else
      # Fall back to URL in preferences
      ui_preferences&.dig("avatar_url")
    end
  end

  # Set avatar from URL (for backward compatibility)
  def avatar_url=(url)
    # Ensure ui_preferences is initialized
    self.ui_preferences ||= {}
    self.ui_preferences = ui_preferences.merge("avatar_url" => url)
  end

  # Check if user has an avatar (either attached or URL)
  def has_avatar?
    avatar.attached? || ui_preferences&.dig("avatar_url").present?
  end

  private

  def set_default_role
    self.role ||= "staff"
  end

  def track_activity_create
    log_activity("user.created")
  end

  def track_activity_update
    if saved_change_to_role?
      log_activity("user.role_changed", { old_role: role_before_last_save, new_role: role })
    end

    if saved_change_to_active?
      status = active? ? "activated" : "deactivated"
      log_activity("user.#{status}")
    end
  end
end
