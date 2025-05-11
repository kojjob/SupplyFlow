class CreateSuppliers < ActiveRecord::Migration[8.0]
  def change
    create_table :suppliers do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name, null: false
      t.string :contact_person
      t.string :email
      t.string :phone
      t.text :address
      t.string :city
      t.string :state
      t.string :postal_code
      t.string :country, default: "Ghana"
      t.string :tax_id
      t.string :registration_number
      t.string :payment_terms
      t.decimal :credit_limit, precision: 10, scale: 2
      t.boolean :active, default: true
      t.text :notes
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :suppliers, [ :organization_id, :name ], unique: true
    add_index :suppliers, :active
    add_index :suppliers, :email
    add_index :suppliers, :phone
  end
end
