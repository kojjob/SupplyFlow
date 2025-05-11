json.extract! order_item, :id, :order_id, :product_id, :quantity, :unit_price, :tax_rate, :tax_amount, :discount_amount, :total_amount, :shipped_quantity, :notes, :metadata, :created_at, :updated_at
json.url order_item_url(order_item, format: :json)
