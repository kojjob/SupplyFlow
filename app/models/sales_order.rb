class SalesOrder < ApplicationRecord
  # Multi-tenancy
  belongs_to :organization
  acts_as_tenant :organization

  # Associations
  belongs_to :customer
  belongs_to :user
  has_many :sales_order_items, dependent: :destroy
  has_many :products, through: :sales_order_items
  has_many :inventory_transactions, as: :reference
  has_many :payments, as: :payable

  # Validations
  validates :order_number, presence: true, uniqueness: { scope: :organization_id }
  validates :status, inclusion: { in: %w[draft pending confirmed processing shipped delivered canceled] }
  validates :payment_status, inclusion: { in: %w[unpaid partial paid refunded] }
  validates :subtotal, :tax_amount, :shipping_amount, :discount_amount, :total_amount,
            numericality: { greater_than_or_equal_to: 0 }

  # Callbacks
  before_validation :set_order_number, on: :create
  before_save :calculate_totals

  # Scopes
  scope :draft, -> { where(status: "draft") }
  scope :pending, -> { where(status: "pending") }
  scope :confirmed, -> { where(status: "confirmed") }
  scope :processing, -> { where(status: "processing") }
  scope :shipped, -> { where(status: "shipped") }
  scope :delivered, -> { where(status: "delivered") }
  scope :canceled, -> { where(status: "canceled") }
  scope :unpaid, -> { where(payment_status: "unpaid") }
  scope :partially_paid, -> { where(payment_status: "partial") }
  scope :paid, -> { where(payment_status: "paid") }
  scope :refunded, -> { where(payment_status: "refunded") }
  scope :by_customer, ->(customer_id) { where(customer_id: customer_id) }
  scope :by_date_range, ->(start_date, end_date) {
    where(order_date: start_date.beginning_of_day..end_date.end_of_day)
  }

  # Class methods
  def self.statuses_for_select
    {
      "Draft" => "draft",
      "Pending" => "pending",
      "Confirmed" => "confirmed",
      "Processing" => "processing",
      "Shipped" => "shipped",
      "Delivered" => "delivered",
      "Canceled" => "canceled"
    }
  end

  def self.payment_statuses_for_select
    {
      "Unpaid" => "unpaid",
      "Partially Paid" => "partial",
      "Paid" => "paid",
      "Refunded" => "refunded"
    }
  end

  # Instance methods
  def total_paid_amount
    payments.sum(:amount)
  end

  def balance_due
    total_amount - total_paid_amount
  end

  def fully_paid?
    balance_due <= 0
  end

  def fully_shipped?
    sales_order_items.all? { |item| item.shipped_quantity >= item.quantity }
  end

  def update_payment_status
    if total_paid_amount <= 0
      update(payment_status: "unpaid")
    elsif total_paid_amount >= total_amount
      update(payment_status: "paid")
    else
      update(payment_status: "partial")
    end
  end

  def ship_items(items_params, user_id)
    return false unless items_params.is_a?(Array)

    ActiveRecord::Base.transaction do
      items_params.each do |item_param|
        item = sales_order_items.find(item_param[:id])
        quantity_to_ship = [ item_param[:quantity].to_i, item.quantity - item.shipped_quantity ].min

        next if quantity_to_ship <= 0

        # Update the shipped quantity
        item.update!(shipped_quantity: item.shipped_quantity + quantity_to_ship)

        # Create inventory transaction
        source_location = Location.find(item_param[:location_id])

        # Find inventory item
        inventory_item = InventoryItem.find_by(
          organization_id: organization_id,
          product_id: item.product_id,
          location_id: source_location.id
        )

        # Skip if inventory item not found or insufficient quantity
        next unless inventory_item && inventory_item.available_quantity >= quantity_to_ship

        # Remove stock and create transaction
        inventory_item.remove_stock(
          quantity_to_ship,
          "sale",
          user_id,
          "Shipped for SO ##{order_number}"
        )
      end

      # Update order status if all items are shipped
      if fully_shipped?
        update(status: "shipped", shipping_date: Date.today)
      else
        update(status: "processing")
      end
    end

    true
  rescue => e
    Rails.logger.error("Error shipping items for SO ##{order_number}: #{e.message}")
    false
  end

  private

  def set_order_number
    return if order_number.present?

    last_order = organization.sales_orders.order(created_at: :desc).first
    last_number = last_order&.order_number.to_s.match(/SO-(\d+)/).try(:[], 1).to_i

    self.order_number = sprintf("SO-%07d", last_number + 1)
  end

  def calculate_totals
    self.subtotal = sales_order_items.sum(&:total_amount)
    self.total_amount = subtotal + tax_amount + shipping_amount - discount_amount
  end
end
