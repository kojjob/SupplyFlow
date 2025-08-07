class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :payable, polymorphic: true, null: false
      t.references :user, null: false, foreign_key: true
      t.string :payment_number, null: false
      t.date :payment_date, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :payment_method, null: false
      t.string :reference_number
      t.text :notes
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :payments, [ :organization_id, :payment_number ], unique: true
    add_index :payments, :payment_date
    add_index :payments, :payment_method
  end
end
