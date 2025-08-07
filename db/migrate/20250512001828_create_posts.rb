class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    unless table_exists?(:posts)
      create_table :posts do |t|
        t.string :title
        t.references :user, null: false, foreign_key: true
        t.datetime :published_at
        t.string :slug
        t.integer :status
        t.string :meta_title
        t.text :meta_description

        t.timestamps
      end
      add_index :posts, :title unless index_exists?(:posts, :title)
      add_index :posts, :published_at unless index_exists?(:posts, :published_at)
      add_index :posts, :slug unless index_exists?(:posts, :slug)
      add_index :posts, :status unless index_exists?(:posts, :status)
    end
  end
end
