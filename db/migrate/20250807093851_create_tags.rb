class CreateTags < ActiveRecord::Migration[8.0]
  def change
    create_table :tags do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.integer :posts_count, default: 0

      t.timestamps
    end
    add_index :tags, :slug, unique: true
    add_index :tags, :name
  end
end
