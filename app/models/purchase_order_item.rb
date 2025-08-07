class PurchaseOrderItem < ApplicationRecord
  # Associations
  belongs_to :purchase_order
  belongs_to :product

  # Validations
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :tax_rate, :tax_amount, :discount_amount, :total_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :received_quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :received_quantity_not_greater_than_quantity

  # Callbacks
  before_save :calculate_amounts
  after_save :update_purchase_order_totals

  # Delegations
  delegate :organization, to: :purchase_order

  # Instance methods
  def remaining_quantity
    quantity - received_quantity
  end

  def fully_received?
    received_quantity >= quantity
  end

  private

  def calculate_amounts
    self.tax_amount = (unit_price * quantity * tax_rate / 100).round(2)
    self.total_amount = (unit_price * quantity) + tax_amount - discount_amount
  end

  def update_purchase_order_totals
    purchase_order.calculate_totals
    purchase_order.save
  end

  def received_quantity_not_greater_than_quantity
    return unless received_quantity && quantity

    if received_quantity > quantity
      errors.add(:received_quantity, "cannot be greater than ordered quantity")
    end
  end
end
