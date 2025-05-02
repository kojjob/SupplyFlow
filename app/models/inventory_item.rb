class InventoryItem < ApplicationRecord
  # Multi-tenancy
  belongs_to :organization
  acts_as_tenant :organization
  
  # Associations
  belongs_to :product
  belongs_to :location
  has_many :inventory_transactions
  
  # Validations
  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :reserved_quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :product_id, uniqueness: { scope: [:organization_id, :location_id] }
  validates :status, inclusion: { in: %w[available reserved damaged expired quarantined] }
  validate :reserved_not_greater_than_quantity
  
  # Scopes
  scope :available, -> { where(status: 'available') }
  scope :reserved, -> { where(status: 'reserved') }
  scope :damaged, -> { where(status: 'damaged') }
  scope :expired, -> { where(status: 'expired') }
  scope :expiring_soon, -> { where('expiry_date <= ? AND expiry_date > ?', 30.days.from_now, Date.today) }
  scope :with_stock, -> { where('quantity > 0') }
  scope :by_product, ->(product_id) { where(product_id: product_id) }
  scope :by_location, ->(location_id) { where(location_id: location_id) }
  
  # Callbacks
  before_save :update_status_based_on_expiry

  # Instance methods
  def available_quantity
    quantity - reserved_quantity
  end
  
  def reserve(amount)
    return false if amount > available_quantity
    
    update(reserved_quantity: reserved_quantity + amount)
  end
  
  def unreserve(amount)
    return false if amount > reserved_quantity
    
    update(reserved_quantity: reserved_quantity - amount)
  end
  
  def add_stock(amount, transaction_type = 'stock_addition', user_id = nil, notes = nil)
    return false if amount < 0
    
    self.class.transaction do
      old_quantity = quantity
      update!(quantity: quantity + amount)
      
      if user_id.present?
        InventoryTransaction.create!(
          organization: organization,
          product: product,
          destination_location: location,
          user_id: user_id,
          transaction_type: transaction_type,
          quantity: amount,
          notes: notes
        )
      end
      
      true
    end
  rescue ActiveRecord::RecordInvalid
    false
  end
  
  def remove_stock(amount, transaction_type = 'stock_removal', user_id = nil, notes = nil)
    return false if amount < 0 || amount > available_quantity
    
    self.class.transaction do
      old_quantity = quantity
      update!(quantity: quantity - amount)
      
      if user_id.present?
        InventoryTransaction.create!(
          organization: organization,
          product: product,
          source_location: location,
          user_id: user_id,
          transaction_type: transaction_type,
          quantity: amount,
          notes: notes
        )
      end
      
      true
    end
  rescue ActiveRecord::RecordInvalid
    false
  end
  
  def transfer_stock(destination_location_id, amount, user_id, notes = nil)
    return false if amount < 0 || amount > available_quantity
    
    destination = InventoryItem.find_or_initialize_by(
      organization_id: organization_id,
      product_id: product_id,
      location_id: destination_location_id
    )
    
    self.class.transaction do
      update!(quantity: quantity - amount)
      
      if destination.new_record?
        destination.quantity = amount
        destination.save!
      else
        destination.update!(quantity: destination.quantity + amount)
      end
      
      InventoryTransaction.create!(
        organization: organization,
        product: product,
        source_location: location,
        destination_location_id: destination_location_id,
        user_id: user_id,
        transaction_type: 'transfer',
        quantity: amount,
        notes: notes
      )
      
      true
    end
  rescue ActiveRecord::RecordInvalid
    false
  end
  
  private
  
  def reserved_not_greater_than_quantity
    if reserved_quantity.present? && quantity.present? && reserved_quantity > quantity
      errors.add(:reserved_quantity, "cannot be greater than total quantity")
    end
  end
  
  def update_status_based_on_expiry
    if product.perishable? && expiry_date.present? && expiry_date < Date.today && status != 'expired'
      self.status = 'expired'
    end
  end
end