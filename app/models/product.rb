class Product < ApplicationRecord
  # Multi-tenancy
  belongs_to :organization
  acts_as_tenant :organization

  # Associations
  has_many :inventory_items, dependent: :destroy
  has_many :inventory_transactions
  has_many :locations, through: :inventory_items

  # Validations
  validates :name, presence: true
  validates :sku, presence: true, uniqueness: { scope: :organization_id }
  validates :cost_price, :selling_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :minimum_stock_level, :reorder_point, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :weight, :length, :width, :height, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_category, ->(category) { where(category: category) }
  scope :low_stock, -> { joins(:inventory_items).group('products.id').having('SUM(inventory_items.quantity) <= products.reorder_point') }
  scope :out_of_stock, -> { joins(:inventory_items).group('products.id').having('SUM(inventory_items.quantity) <= 0') }

  # Class methods
  def self.categories
    distinct.pluck(:category).compact.sort
  end

  def self.brands
    distinct.pluck(:brand).compact.sort
  end

  # Instance methods
  def total_quantity
    inventory_items.sum(:quantity)
  end

  def available_quantity
    inventory_items.sum('quantity - reserved_quantity')
  end

  def reserved_quantity
    inventory_items.sum(:reserved_quantity)
  end

  def low_stock?
    total_quantity <= reorder_point
  end

  def out_of_stock?
    total_quantity <= 0
  end

  def profit_margin
    return nil if selling_price.nil? || cost_price.nil? || cost_price == 0
    ((selling_price - cost_price) / cost_price * 100).round(2)
  end

  def format_dimensions
    dimensions = []
    dimensions << "#{length} #{unit_of_measure}" if length.present?
    dimensions << "#{width} #{unit_of_measure}" if width.present?
    dimensions << "#{height} #{unit_of_measure}" if height.present?
    
    if dimensions.any?
      dimensions.join(' x ')
    else
      "Not specified"
    end
  end
end