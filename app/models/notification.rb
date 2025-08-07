class Notification < ApplicationRecord
  # Associations
  belongs_to :recipient, class_name: 'User', foreign_key: 'recipient_id'
  belongs_to :actor, class_name: 'User', foreign_key: 'actor_id', optional: true
  belongs_to :organization
  belongs_to :notifiable, polymorphic: true, optional: true

  # Validations
  validates :title, presence: true
  validates :message, presence: true
  validates :notification_type, presence: true

  # Scopes
  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_type, ->(type) { where(notification_type: type) }
  scope :high_priority, -> { where(priority: 'high') }
  scope :today, -> { where('created_at >= ?', Date.today) }
  scope :this_week, -> { where('created_at >= ?', 1.week.ago) }

  # Enums
  enum :notification_type, {
    low_stock: 0,
    new_order: 1,
    payment_received: 2,
    order_shipped: 3,
    order_delivered: 4,
    order_canceled: 5,
    purchase_order_received: 6,
    user_activity: 7,
    system: 8,
    warning: 9,
    info: 10,
    success: 11,
    error: 12
  }, default: :system

  enum :priority, {
    low: 0,
    normal: 1,
    medium: 2,
    high: 3
  }, default: :normal

  # Callbacks
  after_create_commit :broadcast_notification
  after_create_commit :send_email_notification, if: :email_enabled?
  after_create_commit :send_push_notification, if: :push_enabled?

  # Instance methods
  def mark_as_read!
    update!(read_at: Time.current) unless read?
  end

  def read?
    read_at.present?
  end

  def unread?
    read_at.nil?
  end

  def email_enabled?
    recipient.notification_preferences&.email_enabled?
  end

  def push_enabled?
    recipient.notification_preferences&.push_enabled?
  end

  # Class methods
  def self.create_for_low_stock(product, current_stock, reorder_level)
    product.organization.users.each do |user_instance| # Renamed to avoid conflict with association
      create!(
        recipient: user_instance,
        organization: product.organization,
        title: "Low Stock Alert",
        message: "#{product.name} is running low on stock. Current stock: #{current_stock} units.",
        notification_type: :low_stock,
        priority: :high,
        notifiable: product,
        data: {
          product_name: product.name,
          sku: product.sku,
          current_stock: current_stock,
          reorder_level: reorder_level
        },
        url: Rails.application.routes.url_helpers.product_path(product)
      )
    end
  end

  def self.create_for_new_order(order)
    order.organization.users.with_role(:admin).each do |user_instance| # Renamed to avoid conflict
      create!(
        recipient: user_instance,
        organization: order.organization,
        title: "New Sales Order Received",
        message: "A new order ##{order.order_number} has been placed by #{order.customer.name}.",
        notification_type: :new_order,
        priority: :medium,
        notifiable: order,
        data: {
          order_number: order.order_number,
          customer_name: order.customer.name,
          amount: order.total_amount,
          status: order.status
        },
        url: Rails.application.routes.url_helpers.sales_order_path(order)
      )
    end
  end

  def self.create_for_payment_received(payment)
    payment.payable.organization.users.with_role(:finance).each do |user_instance| # Renamed
      create!(
        recipient: user_instance,
        organization: payment.payable.organization,
        title: "Payment Received",
        message: "Payment of #{ActionController::Base.helpers.number_to_currency(payment.amount, unit: 'GHS ')} received for #{payment.payable_type} ##{payment.payable.order_number}.",
        notification_type: :payment_received,
        priority: :normal,
        notifiable: payment,
        data: {
          amount: payment.amount,
          payment_method: payment.payment_method,
          reference: payment.transaction_id
        },
        url: Rails.application.routes.url_helpers.payment_path(payment)
      )
    end
  end

  private

  def broadcast_notification
    NotificationBroadcastJob.perform_later(self)
  end

  def send_email_notification
    NotificationMailer.new_notification(self).deliver_later
  end

  def send_push_notification
    # Implement push notification logic here
    # This could use services like Firebase, OneSignal, etc.
  end
end
