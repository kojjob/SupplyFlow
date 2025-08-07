class Tag < ApplicationRecord
  # Associations
  has_many :post_tags, dependent: :destroy
  has_many :posts, through: :post_tags
  
  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :slug, presence: true, uniqueness: { case_sensitive: false }
  
  # Callbacks
  before_validation :generate_slug, if: -> { name.present? && slug.blank? }
  
  # Scopes
  scope :with_posts, -> { joins(:posts).distinct }
  scope :popular, -> { order(posts_count: :desc) }
  scope :alphabetical, -> { order(name: :asc) }
  
  def to_param
    slug
  end
  
  def update_posts_count
    update_column(:posts_count, posts.published.count)
  end
  
  private
  
  def generate_slug
    self.slug = name.parameterize if name.present?
  end
end
