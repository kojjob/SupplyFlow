class Location < ApplicationRecord
  # Multi-tenancy
  belongs_to :organization
  acts_as_tenant :organization
  
  # Associations
  belongs_to :parent_location, class_name: "Location", optional: true
  has_many :child_locations, class_name: "Location", foreign_key: "parent_location_id", dependent: :nullify
  has_many :users, foreign_key: "default_location_id", dependent: :nullify
  
  # Inventory associations
  has_many :inventory_items, dependent: :destroy
  has_many :products, -> { distinct }, through: :inventory_items
  has_many :source_transactions, class_name: "InventoryTransaction", foreign_key: "source_location_id"
  has_many :destination_transactions, class_name: "InventoryTransaction", foreign_key: "destination_location_id"
  
  # Validations
  validates :name, presence: true, uniqueness: { scope: :organization_id }
  
  # Scopes
  scope :active, -> { where(active: true) }
  scope :warehouses, -> { where(location_type: "warehouse") }
  scope :stores, -> { where(location_type: "store") }
  scope :shelves, -> { where(location_type: "shelf") }
  
  # Instance methods
  def full_name
    parent_location.present? ? "#{parent_location.name} > #{name}" : name
  end
  
  def root?
    parent_location_id.nil?
  end
  
  def leaf?
    child_locations.empty?
  end
  
  # Inventory methods
  def total_inventory_count
    inventory_items.sum(:quantity)
  end
  
  def unique_products_count
    inventory_items.where('quantity > 0').count
  end
  
  def inventory_value
    inventory_items.joins(:product).sum('inventory_items.quantity * products.cost_price')
  end
  
  def low_stock_items
    inventory_items.joins(:product)
                   .where('inventory_items.quantity <= products.reorder_point')
                   .where('inventory_items.quantity > 0')
  end
  
  def out_of_stock_items
    inventory_items.where(quantity: 0)
  end
  
  def inventory_transactions
    InventoryTransaction.where("source_location_id = ? OR destination_location_id = ?", id, id)
  end
  
  def add_product(product, quantity = 0)
    inventory_items.find_or_create_by(product: product) do |item|
      item.organization = organization
      item.quantity = quantity
    end
  end
end
