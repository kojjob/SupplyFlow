class Order < ApplicationRecord
  belongs_to :organization
  belongs_to :customer
  belongs_to :user
end
