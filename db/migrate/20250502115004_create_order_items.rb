class CreateOrderItems < ActiveRecord::Migration[8.0]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, null: false
      t.decimal :unit_price, precision: 10, scale: 2, null: false
      t.decimal :tax_rate, precision: 5, scale: 2, default: 0.0
      t.decimal :tax_amount, precision: 10, scale: 2, default: 0.0
      t.decimal :discount_amount, precision: 10, scale: 2, default: 0.0
      t.decimal :total_amount, precision: 10, scale: 2, default: 0.0
      t.integer :shipped_quantity, default: 0
      t.text :notes
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :order_items, [ :order_id, :product_id ], unique: true
  end
end
