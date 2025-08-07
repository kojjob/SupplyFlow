class Post < ApplicationRecord
  belongs_to :user # Author
  has_rich_text :content
  has_one_attached :featured_image
  has_one_attached :video_file
  has_one_attached :audio_file
  has_many_attached :media_files
  
  # Associations for categories and tags
  has_many :post_categories, dependent: :destroy
  has_many :categories, through: :post_categories
  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags
  has_many :reviews, dependent: :destroy

  # Enums
  enum :status, { draft: 0, published: 1, archived: 2 }, default: :draft
  enum :media_type, { 
    article: 'article',
    video: 'video',
    audio: 'audio',
    podcast: 'podcast',
    infographic: 'infographic',
    gallery: 'gallery'
  }, default: :article, prefix: true
  enum :schema_type, { 
    Article: 'Article',
    BlogPosting: 'BlogPosting',
    NewsArticle: 'NewsArticle',
    VideoObject: 'VideoObject',
    AudioObject: 'AudioObject',
    HowTo: 'HowTo',
    FAQ: 'FAQ',
    Recipe: 'Recipe'
  }, default: :Article, prefix: true

  # Validations
  validates :title, presence: true, length: { maximum: 100 }
  validates :slug, presence: true, uniqueness: { case_sensitive: false }
  validates :content, presence: true
  validates :user_id, presence: true
  validates :meta_title, length: { maximum: 60 }, allow_blank: true
  validates :meta_description, length: { maximum: 160 }, allow_blank: true
  validates :excerpt, length: { maximum: 300 }, allow_blank: true
  validates :focus_keyword, length: { maximum: 50 }, allow_blank: true
  
  # Media validations
  validates :youtube_url, format: { 
    with: /\A(https?:\/\/)?(www\.)?(youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)[\w-]+(&[\w=]*)?/,
    allow_blank: true 
  }
  validates :vimeo_url, format: { 
    with: /\A(https?:\/\/)?(www\.)?(vimeo\.com\/)[\d]+/,
    allow_blank: true 
  }

  # Callbacks
  before_validation :generate_slug, if: -> { title.present? && slug.blank? }
  before_validation :generate_excerpt, if: -> { excerpt.blank? && content.present? }
  before_save :generate_meta_tags
  before_save :calculate_seo_score
  before_save :calculate_readability_score
  before_save :extract_media_metadata
  after_save :update_category_counts
  after_destroy :update_category_counts

  # Scopes
  scope :published, -> { where(status: :published).where("published_at <= ?", Time.current).order(published_at: :desc) }
  scope :drafts, -> { where(status: :draft) }
  scope :archived, -> { where(status: :archived) }
  scope :seo_optimized, -> { where("seo_score >= ?", 70) }
  scope :indexable, -> { where(no_index: false) }
  scope :with_media, -> { where.not(media_type: 'article') }
  scope :videos, -> { where(media_type: 'video') }
  scope :audio_content, -> { where(media_type: ['audio', 'podcast']) }

  # Instance methods
  def published?
    status == "published" && published_at.present? && published_at <= Time.current
  end

  def to_param
    slug # Use slug for URLs
  end

  def reading_time
    return media_duration_display if media_type != 'article' && media_duration.present?
    
    words_per_minute = 200
    text_content = self.content&.to_plain_text || ""
    words = text_content.split.size
    minutes = (words / words_per_minute.to_f).ceil
    minutes = 1 if minutes == 0 && words > 0
    "#{minutes} min read"
  end
  
  def media_duration_display
    return nil unless media_duration.present?
    
    hours = media_duration / 3600
    minutes = (media_duration % 3600) / 60
    seconds = media_duration % 60
    
    if hours > 0
      "#{hours}h #{minutes}m"
    elsif minutes > 0
      "#{minutes}m #{seconds}s"
    else
      "#{seconds}s"
    end
  end
  
  def has_media?
    video_url.present? || audio_url.present? || youtube_url.present? || 
    vimeo_url.present? || podcast_url.present? || embed_code.present? ||
    video_file.attached? || audio_file.attached?
  end
  
  def primary_media_url
    case media_type
    when 'video'
      youtube_url || vimeo_url || video_url
    when 'audio', 'podcast'
      podcast_url || audio_url
    else
      nil
    end
  end
  
  def thumbnail_url
    return media_thumbnail if media_thumbnail.present?
    return extract_youtube_thumbnail if youtube_url.present?
    return extract_vimeo_thumbnail if vimeo_url.present?
    featured_image.attached? ? featured_image : nil
  end
  
  def canonical_url_with_default
    canonical_url.presence || Rails.application.routes.url_helpers.post_url(self, host: Rails.application.config.action_mailer.default_url_options[:host])
  end
  
  def structured_data
    {
      "@context": "https://schema.org",
      "@type": schema_type || "Article",
      "headline": title,
      "description": meta_description || excerpt,
      "image": featured_image.attached? ? featured_image : nil,
      "author": {
        "@type": "Person",
        "name": user.name,
        "url": user.website_url
      },
      "publisher": {
        "@type": "Organization",
        "name": "SupplyFlow",
        "logo": {
          "@type": "ImageObject",
          "url": Rails.application.config.logo_url
        }
      },
      "datePublished": published_at&.iso8601,
      "dateModified": updated_at.iso8601,
      "mainEntityOfPage": {
        "@type": "WebPage",
        "@id": canonical_url_with_default
      },
      "keywords": keywords,
      "articleSection": categories.pluck(:name).join(", ")
    }.merge(media_structured_data)
  end

  private

  def generate_slug
    self.slug = title.parameterize if title.present?
  end
  
  def generate_excerpt
    self.excerpt = content.to_plain_text.truncate(280) if content.present?
  end
  
  def generate_meta_tags
    self.meta_title ||= title.truncate(60) if title.present?
    self.meta_description ||= excerpt&.truncate(160) || content.to_plain_text.truncate(160)
  end
  
  def calculate_seo_score
    score = 0
    score += 20 if meta_title.present? && meta_title.length.between?(30, 60)
    score += 20 if meta_description.present? && meta_description.length.between?(120, 160)
    score += 15 if focus_keyword.present? && title.downcase.include?(focus_keyword.downcase)
    score += 15 if excerpt.present?
    score += 10 if featured_image.attached?
    score += 10 if slug.present? && slug.include?(focus_keyword&.parameterize || '')
    score += 10 if categories.any?
    self.seo_score = score
  end
  
  def calculate_readability_score
    return unless content.present?
    text = content.to_plain_text
    sentences = text.split(/[.!?]+/).length
    words = text.split.length
    syllables = text.downcase.scan(/[aeiou]/).length
    
    # Flesch Reading Ease formula
    score = 206.835 - 1.015 * (words.to_f / sentences) - 84.6 * (syllables.to_f / words)
    self.readability_score = score.clamp(0, 100).round
  end
  
  def extract_media_metadata
    if youtube_url.present?
      video_id = extract_youtube_id
      self.media_metadata ||= {}
      self.media_metadata['youtube_id'] = video_id
      self.media_metadata['embed_url'] = "https://www.youtube.com/embed/#{video_id}"
    end
    
    if vimeo_url.present?
      video_id = extract_vimeo_id
      self.media_metadata ||= {}
      self.media_metadata['vimeo_id'] = video_id
      self.media_metadata['embed_url'] = "https://player.vimeo.com/video/#{video_id}"
    end
  end
  
  def extract_youtube_id
    youtube_url.match(/(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([\w-]+)/).try(:[], 1)
  end
  
  def extract_vimeo_id
    vimeo_url.match(/vimeo\.com\/(\d+)/).try(:[], 1)
  end
  
  def extract_youtube_thumbnail
    "https://img.youtube.com/vi/#{extract_youtube_id}/maxresdefault.jpg" if extract_youtube_id
  end
  
  def extract_vimeo_thumbnail
    # Note: Vimeo thumbnails require API call, placeholder for now
    nil
  end
  
  def media_structured_data
    case media_type
    when 'video'
      {
        "video": {
          "@type": "VideoObject",
          "name": title,
          "description": excerpt,
          "thumbnailUrl": thumbnail_url,
          "uploadDate": published_at&.iso8601,
          "duration": media_duration ? "PT#{media_duration}S" : nil,
          "embedUrl": media_metadata&.dig('embed_url')
        }
      }
    when 'audio', 'podcast'
      {
        "audio": {
          "@type": "AudioObject",
          "name": title,
          "description": excerpt,
          "duration": media_duration ? "PT#{media_duration}S" : nil,
          "contentUrl": audio_url || podcast_url
        }
      }
    else
      {}
    end
  end
  
  def update_category_counts
    categories.each(&:update_posts_count)
    tags.each(&:update_posts_count)
  end
end
