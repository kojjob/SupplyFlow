class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :order_number, null: false
      t.string :status, default: "draft"
      t.date :order_date
      t.date :shipping_date
      t.date :delivery_date
      t.text :shipping_address
      t.text :billing_address
      t.decimal :subtotal, precision: 10, scale: 2, default: 0.0
      t.decimal :tax_amount, precision: 10, scale: 2, default: 0.0
      t.decimal :shipping_amount, precision: 10, scale: 2, default: 0.0
      t.decimal :discount_amount, precision: 10, scale: 2, default: 0.0
      t.decimal :total_amount, precision: 10, scale: 2, default: 0.0
      t.string :payment_status, default: "unpaid"
      t.string :shipping_method
      t.string :tracking_number
      t.string :currency, default: "GHS"
      t.text :notes
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :orders, [ :organization_id, :order_number ], unique: true
    add_index :orders, :order_date
    add_index :orders, :shipping_date
    add_index :orders, :delivery_date
    add_index :orders, :status
    add_index :orders, :payment_status
    add_index :orders, :tracking_number
  end
end
