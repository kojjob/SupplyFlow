class CreateUserActivities < ActiveRecord::Migration[8.0]
  def change
    create_table :user_activities do |t|
      t.references :user, null: false, foreign_key: true
      t.references :organization, null: false, foreign_key: true
      t.string :action, null: false
      t.jsonb :details, default: {}
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end

    add_index :user_activities, [ :user_id, :created_at ]
    add_index :user_activities, [ :organization_id, :created_at ]
    add_index :user_activities, :action
  end
end
