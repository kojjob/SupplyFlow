class Payment < ApplicationRecord
  # Multi-tenancy
  belongs_to :organization
  acts_as_tenant :organization

  # Associations
  belongs_to :payable, polymorphic: true
  belongs_to :user

  # Validations
  validates :payment_number, presence: true, uniqueness: { scope: :organization_id }
  validates :payment_date, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_method, presence: true, inclusion: { in: %w[cash credit_card bank_transfer mobile_money check other] }

  # Callbacks
  before_validation :set_payment_number, on: :create
  after_create :update_order_payment_status
  after_destroy :update_order_payment_status

  # Scopes
  scope :by_date_range, ->(start_date, end_date) {
    where(payment_date: start_date.beginning_of_day..end_date.end_of_day)
  }
  scope :by_payment_method, ->(method) { where(payment_method: method) }

  # Class methods
  def self.payment_methods_for_select
    {
      "Cash" => "cash",
      "Credit Card" => "credit_card",
      "Bank Transfer" => "bank_transfer",
      "Mobile Money" => "mobile_money",
      "Check" => "check",
      "Other" => "other"
    }
  end

  private

  def set_payment_number
    return if payment_number.present?

    last_payment = organization.payments.order(created_at: :desc).first
    last_number = last_payment&.payment_number.to_s.match(/PMT-(\d+)/).try(:[], 1).to_i

    self.payment_number = sprintf("PMT-%07d", last_number + 1)
  end

  def update_order_payment_status
    if payable.respond_to?(:update_payment_status)
      payable.update_payment_status
    end
  end
end
