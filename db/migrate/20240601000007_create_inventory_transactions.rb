class CreateInventoryTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :inventory_transactions do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.references :source_location, foreign_key: { to_table: :locations }
      t.references :destination_location, foreign_key: { to_table: :locations }
      t.references :user, null: false, foreign_key: true
      t.string :transaction_type, null: false
      t.integer :quantity, null: false
      t.string :reference_number
      t.references :reference, polymorphic: true
      t.text :notes
      t.decimal :unit_cost, precision: 10, scale: 2
      t.decimal :unit_price, precision: 10, scale: 2
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :inventory_transactions, :transaction_type
    add_index :inventory_transactions, :reference_number
  end
end
