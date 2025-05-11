class CreateLocations < ActiveRecord::Migration[8.0]
  def change
    create_table :locations do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name, null: false
      t.string :address
      t.string :city
      t.string :state
      t.string :postal_code
      t.string :country, default: "Ghana"
      t.string :phone
      t.string :email
      t.text :notes
      t.boolean :active, default: true
      t.string :location_type, default: "warehouse" # warehouse, store, shelf, etc.
      t.references :parent_location, foreign_key: { to_table: :locations }, null: true

      t.timestamps
    end

    add_index :locations, [ :organization_id, :name ], unique: true
    add_index :locations, :active
  end
end
