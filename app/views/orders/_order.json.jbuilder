json.extract! order, :id, :organization_id, :customer_id, :user_id, :order_number, :status, :order_date, :shipping_date, :delivery_date, :shipping_address, :billing_address, :subtotal, :tax_amount, :shipping_amount, :discount_amount, :total_amount, :payment_status, :shipping_method, :tracking_number, :currency, :notes, :metadata, :created_at, :updated_at
json.url order_url(order, format: :json)
