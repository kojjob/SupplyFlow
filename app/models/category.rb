class Category < ApplicationRecord
  # Associations
  has_many :post_categories, dependent: :destroy
  has_many :posts, through: :post_categories
  
  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :slug, presence: true, uniqueness: { case_sensitive: false }
  
  # Callbacks
  before_validation :generate_slug, if: -> { name.present? && slug.blank? }
  before_save :generate_meta_tags
  
  # Scopes
  scope :with_posts, -> { joins(:posts).distinct }
  scope :ordered, -> { order(position: :asc, name: :asc) }
  scope :popular, -> { order(posts_count: :desc) }
  
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
  
  def generate_meta_tags
    self.meta_title ||= "#{name} Articles | SupplyFlow Blog"
    self.meta_description ||= description || "Explore our collection of #{name.downcase} articles and insights on SupplyFlow Blog."
  end
end
