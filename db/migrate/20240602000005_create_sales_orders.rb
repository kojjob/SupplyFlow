class CreateSalesOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :sales_orders do |t|
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
      t.decimal :subtotal, precision: 10, scale: 2, default: 0
      t.decimal :tax_amount, precision: 10, scale: 2, default: 0
      t.decimal :shipping_amount, precision: 10, scale: 2, default: 0
      t.decimal :discount_amount, precision: 10, scale: 2, default: 0
      t.decimal :total_amount, precision: 10, scale: 2, default: 0
      t.string :payment_status, default: "unpaid"
      t.text :notes
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :sales_orders, [ :organization_id, :order_number ], unique: true
    add_index :sales_orders, :status
    add_index :sales_orders, :payment_status
    add_index :sales_orders, :order_date
    add_index :sales_orders, :shipping_date
    add_index :sales_orders, :delivery_date
  end
end
