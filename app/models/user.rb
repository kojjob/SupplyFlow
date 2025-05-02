class User < ApplicationRecord
  # Include default devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         # Disable these modules temporarily for development
         #:confirmable, :lockable, :timeoutable, :trackable

  # Multi-tenancy
  belongs_to :organization, optional: true
  # Disable for now
  # acts_as_tenant :organization

  # Make sure organization is present after creation - disabled temporarily
  # validates :organization_id, presence: true, on: :create

  # Associations
  belongs_to :default_location, class_name: "Location", optional: true
  belongs_to :created_by, class_name: "User", optional: true
  has_many :created_users, class_name: "User", foreign_key: "created_by_id", dependent: :nullify
  has_many :user_activities, dependent: :destroy

  # Validations
  validates :name, presence: true
  # Disable this constraint for now
  # validates :email, presence: true, uniqueness: { scope: :organization_id }
  validates :email, presence: true, uniqueness: true
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
    update(device_tokens: device_tokens - [token])
  end

  # UI preferences
  def theme
    ui_preferences["theme"] || "light"
  end

  def theme=(value)
    self.ui_preferences = ui_preferences.merge("theme" => value)
  end

  def locale
    ui_preferences["locale"] || "en"
  end

  def locale=(value)
    self.ui_preferences = ui_preferences.merge("locale" => value)
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
