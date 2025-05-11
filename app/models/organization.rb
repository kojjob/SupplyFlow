class Organization < ApplicationRecord
  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true, uniqueness: { case_sensitive: false, allow_blank: true }

  # Associations
  has_one_attached :logo
  has_many :users, dependent: :destroy
  has_many :locations, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :inventory_items, dependent: :destroy
  has_many :inventory_transactions, dependent: :destroy

  # Order associations
  has_many :suppliers, dependent: :destroy
  has_many :customers, dependent: :destroy
  has_many :purchase_orders, dependent: :destroy
  has_many :sales_orders, dependent: :destroy
  has_many :payments, dependent: :destroy

  # Scopes
  scope :active, -> { where(active: true) }

  # Instance methods
  def primary_contact
    users.find_by(role: "owner") || users.first
  end

  # Settings accessors
  def currency
    settings["currency"] || "GHS"
  end

  def currency=(code)
    self.settings = settings.merge("currency" => code)
  end

  # Inventory summary
  def total_products
    products.count
  end

  def total_inventory_value
    inventory_items.joins(:product).sum("inventory_items.quantity * products.cost_price")
  end

  def low_stock_items
    Product.joins(:inventory_items)
           .where(organization_id: id)
           .group("products.id")
           .having("SUM(inventory_items.quantity) <= products.reorder_point")
           .count
  end
end
