class SalesOrderItem < ApplicationRecord
  # Associations
  belongs_to :sales_order
  belongs_to :product

  # Validations
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :tax_rate, :tax_amount, :discount_amount, :total_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :shipped_quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :shipped_quantity_not_greater_than_quantity

  # Callbacks
  before_save :calculate_amounts
  after_save :update_sales_order_totals

  # Delegations
  delegate :organization, to: :sales_order

  # Instance methods
  def remaining_quantity
    quantity - shipped_quantity
  end

  def fully_shipped?
    shipped_quantity >= quantity
  end

  private

  def calculate_amounts
    self.tax_amount = (unit_price * quantity * tax_rate / 100).round(2)
    self.total_amount = (unit_price * quantity) + tax_amount - discount_amount
  end

  def update_sales_order_totals
    sales_order.calculate_totals
    sales_order.save
  end

  def shipped_quantity_not_greater_than_quantity
    return unless shipped_quantity && quantity

    if shipped_quantity > quantity
      errors.add(:shipped_quantity, "cannot be greater than ordered quantity")
    end
  end
end
