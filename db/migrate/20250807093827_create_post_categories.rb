class CreatePostCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :post_categories do |t|
      t.references :post, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.integer :position, default: 0

      t.timestamps
    end
    
    add_index :post_categories, [:post_id, :category_id], unique: true
    add_index :post_categories, :position
  end
end
