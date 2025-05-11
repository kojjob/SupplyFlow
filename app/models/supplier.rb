class Supplier < ApplicationRecord
  # Multi-tenancy
  belongs_to :organization
  acts_as_tenant :organization

  # Associations
  has_many :purchase_orders, dependent: :restrict_with_error

  # Validations
  validates :name, presence: true, uniqueness: { scope: :organization_id }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :credit_limit, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Scopes
  scope :active, -> { where(active: true) }

  # Instance methods
  def full_address
    [ address, city, state, postal_code, country ].compact.join(", ")
  end
end
