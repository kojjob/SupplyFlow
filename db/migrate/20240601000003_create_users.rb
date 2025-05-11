class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      # Basic information
      t.string :name, null: false
      t.string :phone_number

      # Organizational context
      t.references :organization, null: false, foreign_key: true
      t.string :role, default: "staff"

      # Permissions & Security
      t.boolean :active, default: true
      t.datetime :last_login_at

      # Application-specific
      t.references :default_location, foreign_key: { to_table: :locations }, null: true
      t.jsonb :notification_preferences, default: { "email" => true, "in_app" => true }
      t.jsonb :ui_preferences, default: {}

      # Device & Offline Support
      t.boolean :offline_access_enabled, default: false
      t.datetime :last_sync_at
      t.jsonb :device_tokens, default: []

      # Activity Tracking
      t.datetime :last_activity_at
      t.references :created_by, foreign_key: { to_table: :users }, null: true

      # Devise fields
      ## Database authenticatable
      t.string :email, null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email

      ## Lockable
      t.integer  :failed_attempts, default: 0, null: false
      t.string   :unlock_token
      t.datetime :locked_at

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token, unique: true
    add_index :users, :unlock_token, unique: true
    add_index :users, [ :organization_id, :email ], unique: true
    add_index :users, [ :organization_id, :role ]
    add_index :users, :active
  end
end
