class Review < ApplicationRecord
  belongs_to :post
  belongs_to :user

  # Validations
  validates :body, presence: true, length: { minimum: 5 }
  validates :rating, presence: true, numericality: { 
    only_integer: true, 
    greater_than_or_equal_to: 1, 
    less_than_or_equal_to: 5 
  }
  validates :user_id, presence: true
  validates :post_id, presence: true
  
  # A user can only review a post once
  validates :user_id, uniqueness: { scope: :post_id, message: "has already reviewed this post" }
end
