class CreateOrganizations < ActiveRecord::Migration[8.0]
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.string :address
      t.string :city
      t.string :state
      t.string :postal_code
      t.string :country, default: "Ghana"
      t.string :phone
      t.string :email
      t.string :website
      t.string :tax_id
      t.string :registration_number
      t.text :notes
      t.boolean :active, default: true
      t.string :time_zone, default: "Africa/Accra"
      t.jsonb :settings, default: {}

      t.timestamps
    end

    add_index :organizations, :name
    add_index :organizations, :email
    add_index :organizations, :active
  end
end
