class CreatePurchaseOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :purchase_orders do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :supplier, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :order_number, null: false
      t.string :status, default: "draft"
      t.date :order_date
      t.date :expected_delivery_date
      t.date :delivery_date
      t.text :shipping_address
      t.text :billing_address
      t.decimal :subtotal, precision: 10, scale: 2, default: 0
      t.decimal :tax_amount, precision: 10, scale: 2, default: 0
      t.decimal :shipping_amount, precision: 10, scale: 2, default: 0
      t.decimal :discount_amount, precision: 10, scale: 2, default: 0
      t.decimal :total_amount, precision: 10, scale: 2, default: 0
      t.text :notes
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :purchase_orders, [ :organization_id, :order_number ], unique: true
    add_index :purchase_orders, :status
    add_index :purchase_orders, :order_date
    add_index :purchase_orders, :expected_delivery_date
    add_index :purchase_orders, :delivery_date
  end
end
