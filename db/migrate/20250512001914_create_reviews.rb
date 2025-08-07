class CreateReviews < ActiveRecord::Migration[8.0]
  def change
    unless table_exists?(:reviews)
      create_table :reviews do |t|
        t.references :post, null: false, foreign_key: true
        t.references :user, null: false, foreign_key: true
        t.text :body
        t.integer :rating

        t.timestamps
      end
    end
  end
end
