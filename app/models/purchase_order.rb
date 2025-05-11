class PurchaseOrder < ApplicationRecord
  # Multi-tenancy
  belongs_to :organization
  acts_as_tenant :organization

  # Associations
  belongs_to :supplier
  belongs_to :user
  has_many :purchase_order_items, dependent: :destroy
  accepts_nested_attributes_for :purchase_order_items, allow_destroy: true
  has_many :products, through: :purchase_order_items
  has_many :inventory_transactions, as: :reference
  has_many :payments, as: :payable

  # Validations
  validates :order_number, presence: true, uniqueness: { scope: :organization_id }
  validates :status, inclusion: { in: %w[draft pending approved received canceled] }
  validates :subtotal, :tax_amount, :shipping_amount, :discount_amount, :total_amount,
            numericality: { greater_than_or_equal_to: 0 }

  # Callbacks
  before_validation :set_order_number, on: :create
  before_save :calculate_totals

  # Scopes
  scope :draft, -> { where(status: "draft") }
  scope :pending, -> { where(status: "pending") }
  scope :approved, -> { where(status: "approved") }
  scope :received, -> { where(status: "received") }
  scope :canceled, -> { where(status: "canceled") }
  scope :by_supplier, ->(supplier_id) { where(supplier_id: supplier_id) }
  scope :by_date_range, ->(start_date, end_date) {
    where(order_date: start_date.beginning_of_day..end_date.end_of_day)
  }

  # Class methods
  def self.statuses_for_select
    {
      "Draft" => "draft",
      "Pending" => "pending",
      "Approved" => "approved",
      "Received" => "received",
      "Canceled" => "canceled"
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

  def fully_received?
    purchase_order_items.all? { |item| item.received_quantity >= item.quantity }
  end

  def receive_items(items_params, user_id)
    return false unless items_params.is_a?(Array)

    ActiveRecord::Base.transaction do
      items_params.each do |item_param|
        item = purchase_order_items.find(item_param[:id])
        quantity_to_receive = [ item_param[:quantity].to_i, item.quantity - item.received_quantity ].min

        next if quantity_to_receive <= 0

        # Update the received quantity
        item.update!(received_quantity: item.received_quantity + quantity_to_receive)

        # Create inventory transaction
        location = Location.find(item_param[:location_id])

        # Find or create inventory item
        inventory_item = InventoryItem.find_or_initialize_by(
          organization_id: organization_id,
          product_id: item.product_id,
          location_id: location.id
        )

        # Set organization for new records
        inventory_item.organization_id = organization_id if inventory_item.new_record?

        # Add stock and create transaction
        inventory_item.add_stock(
          quantity_to_receive,
          "purchase",
          user_id,
          "Received from PO ##{order_number}"
        )
      end

      # Update order status if all items are received
      update(status: "received") if fully_received?
    end

    true
  rescue => e
    Rails.logger.error("Error receiving items for PO ##{order_number}: #{e.message}")
    false
  end

  private

  def set_order_number
    return if order_number.present?

    last_order = organization.purchase_orders.order(created_at: :desc).first
    last_number = last_order&.order_number.to_s.match(/PO-(\d+)/).try(:[], 1).to_i

    self.order_number = sprintf("PO-%07d", last_number + 1)
  end

  def calculate_totals
    self.subtotal = purchase_order_items.sum(&:total_amount)
    self.total_amount = subtotal + tax_amount + shipping_amount - discount_amount
  end
end
