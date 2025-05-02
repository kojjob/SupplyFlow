class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name, null: false
      t.string :sku, null: false
      t.text :description
      t.string :barcode
      t.string :category
      t.string :brand
      t.string :model
      t.string :unit_of_measure, default: "unit"
      t.decimal :cost_price, precision: 10, scale: 2
      t.decimal :selling_price, precision: 10, scale: 2
      t.decimal :weight, precision: 8, scale: 2
      t.decimal :length, precision: 8, scale: 2
      t.decimal :width, precision: 8, scale: 2
      t.decimal :height, precision: 8, scale: 2
      t.integer :minimum_stock_level, default: 0
      t.integer :reorder_point, default: 0
      t.boolean :active, default: true
      t.boolean :perishable, default: false
      t.date :expiry_date
      t.jsonb :custom_fields, default: {}
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :products, [:organization_id, :sku], unique: true
    add_index :products, [:organization_id, :name]
    add_index :products, :barcode
    add_index :products, :active
    add_index :products, :category
  end
end