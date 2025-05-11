class InventoryTransaction < ApplicationRecord
  # Multi-tenancy
  belongs_to :organization
  acts_as_tenant :organization

  # Associations
  belongs_to :product
  belongs_to :source_location, class_name: "Location", optional: true
  belongs_to :destination_location, class_name: "Location", optional: true
  belongs_to :user
  belongs_to :reference, polymorphic: true, optional: true

  # Validations
  validates :transaction_type, presence: true, inclusion: {
    in: %w[
      purchase receipt return transfer adjustment
      sale shipment damage expiry stock_count
      stock_addition stock_removal reservation unreservation
    ]
  }
  validates :quantity, presence: true, numericality: { only_integer: true, other_than: 0 }
  validate :source_or_destination_present
  validate :validate_locations_in_same_organization

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_product, ->(product_id) { where(product_id: product_id) }
  scope :by_location, ->(location_id) {
    where("source_location_id = ? OR destination_location_id = ?", location_id, location_id)
  }
  scope :by_type, ->(type) { where(transaction_type: type) }
  scope :by_date_range, ->(start_date, end_date) {
    where(created_at: start_date.beginning_of_day..end_date.end_of_day)
  }
  scope :inbound, -> {
    where(transaction_type: %w[purchase receipt return stock_addition])
  }
  scope :outbound, -> {
    where(transaction_type: %w[sale shipment damage expiry stock_removal])
  }
  scope :transfers, -> { where(transaction_type: "transfer") }

  # Class methods
  def self.transaction_types_for_select
    {
      "Purchase" => "purchase",
      "Receipt" => "receipt",
      "Return" => "return",
      "Transfer" => "transfer",
      "Adjustment" => "adjustment",
      "Sale" => "sale",
      "Shipment" => "shipment",
      "Damage" => "damage",
      "Expiry" => "expiry",
      "Stock Count" => "stock_count",
      "Stock Addition" => "stock_addition",
      "Stock Removal" => "stock_removal",
      "Reservation" => "reservation",
      "Unreservation" => "unreservation"
    }
  end

  # Instance methods
  def inbound?
    %w[purchase receipt return stock_addition].include?(transaction_type)
  end

  def outbound?
    %w[sale shipment damage expiry stock_removal].include?(transaction_type)
  end

  def transfer?
    transaction_type == "transfer"
  end

  def transaction_type_name
    self.class.transaction_types_for_select.invert[transaction_type]
  end

  def location_summary
    if inbound?
      "→ #{destination_location&.name || 'Unknown'}"
    elsif outbound?
      "#{source_location&.name || 'Unknown'} →"
    elsif transfer?
      "#{source_location&.name || 'Unknown'} → #{destination_location&.name || 'Unknown'}"
    else
      "#{source_location&.name || ''} #{destination_location&.name || ''}"
    end
  end

  private

  def source_or_destination_present
    if source_location.blank? && destination_location.blank?
      errors.add(:base, "Either source location or destination location must be present")
    end

    if inbound? && destination_location.blank?
      errors.add(:destination_location, "must be present for inbound transactions")
    end

    if outbound? && source_location.blank?
      errors.add(:source_location, "must be present for outbound transactions")
    end

    if transfer? && (source_location.blank? || destination_location.blank?)
      errors.add(:base, "Both source and destination locations must be present for transfers")
    end
  end

  def validate_locations_in_same_organization
    if source_location.present? && source_location.organization_id != organization_id
      errors.add(:source_location, "must belong to the same organization")
    end

    if destination_location.present? && destination_location.organization_id != organization_id
      errors.add(:destination_location, "must belong to the same organization")
    end
  end
end
