class CreateSolidCableMessages < ActiveRecord::Migration[8.0]
  def change
    # Drop the table if it exists to ensure a clean slate and prevent duplicate table errors.
    # This also handles cases where the table might exist with an incorrect schema.
    drop_table :solid_cable_messages, if_exists: true

    # Recreate the table using the schema from db/cable_schema.rb (Solid Cable's expected schema)
    create_table :solid_cable_messages do |t| # Note: force: :cascade is implied by drop/create
      t.binary "channel", limit: 1024, null: false
      t.binary "payload", limit: 536870912, null: false # Equivalent to :blob with a large limit
      t.datetime "created_at", null: false
      t.integer "channel_hash", limit: 8, null: false # This will be a bigint
    end

    # Add indexes as defined in db/cable_schema.rb
    # Note: The names for indexes are explicitly set to match db/cable_schema.rb
    add_index :solid_cable_messages, :channel, name: "index_solid_cable_messages_on_channel"
    add_index :solid_cable_messages, :channel_hash, name: "index_solid_cable_messages_on_channel_hash"
    add_index :solid_cable_messages, :created_at, name: "index_solid_cable_messages_on_created_at"
  end
end
