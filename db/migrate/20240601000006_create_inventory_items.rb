class CreateInventoryItems < ActiveRecord::Migration[8.0]
  def change
    create_table :inventory_items do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.references :location, null: false, foreign_key: true
      t.integer :quantity, default: 0
      t.integer :reserved_quantity, default: 0
      t.string :lot_number
      t.string :serial_number
      t.date :expiry_date
      t.date :manufactured_date
      t.date :received_date
      t.string :status, default: "available"
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :inventory_items, [:product_id, :location_id], unique: true
    add_index :inventory_items, :status
    add_index :inventory_items, :lot_number
    add_index :inventory_items, :serial_number
  end
end