class AddDetailsToNotifications < ActiveRecord::Migration[8.0]
  def change
    add_column :notifications, :title, :string, null: false
    add_column :notifications, :notification_type, :integer, default: 8 # system
    add_column :notifications, :priority, :integer, default: 1 # normal
    add_column :notifications, :data, :jsonb, default: {}
    add_reference :notifications, :organization, null: false, foreign_key: true
  end
end
