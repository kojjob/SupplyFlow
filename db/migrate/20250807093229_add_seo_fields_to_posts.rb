class AddSeoFieldsToPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :excerpt, :text
    add_column :posts, :keywords, :string
    add_column :posts, :canonical_url, :string
    add_column :posts, :og_image, :string
    add_column :posts, :twitter_image, :string
    add_column :posts, :no_index, :boolean, default: false
    add_column :posts, :schema_type, :string, default: 'Article'
    add_column :posts, :focus_keyword, :string
    add_column :posts, :seo_score, :integer
    add_column :posts, :readability_score, :integer
    
    # Add indexes for better query performance
    add_index :posts, :no_index
    add_index :posts, :schema_type
    add_index :posts, :keywords
  end
end
