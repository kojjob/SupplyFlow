module SeoHelper
  def page_title(title = nil)
    if title.present?
      "#{title} | SupplyFlow"
    else
      content_for(:title) || "SupplyFlow - Streamline Your Supply Chain"
    end
  end
  
  def meta_description(description = nil)
    description || content_for(:meta_description) || "SupplyFlow helps businesses optimize their supply chain operations with powerful inventory management and logistics solutions."
  end
  
  def canonical_url(url = nil)
    url || request.original_url
  end
  
  def og_image_url(image = nil)
    if image.present?
      if image.is_a?(String)
        image.start_with?('http') ? image : asset_url(image)
      elsif image.respond_to?(:url)
        image.url
      end
    else
      asset_url('main-dashboard.png')
    end
  end
  
  def structured_data_script(data)
    content_tag :script, type: 'application/ld+json' do
      data.to_json.html_safe
    end
  end
  
  def breadcrumb_structured_data(breadcrumbs)
    structured_data = {
      "@context": "https://schema.org",
      "@type": "BreadcrumbList",
      "itemListElement": breadcrumbs.map.with_index do |breadcrumb, index|
        {
          "@type": "ListItem",
          "position": index + 1,
          "name": breadcrumb[:name],
          "item": breadcrumb[:url]
        }
      end
    }
    
    structured_data_script(structured_data)
  end
  
  def organization_structured_data
    {
      "@context": "https://schema.org",
      "@type": "Organization",
      "name": "SupplyFlow",
      "url": root_url,
      "logo": og_image_url,
      "description": "Streamline your supply chain operations with SupplyFlow's powerful inventory management and logistics solutions.",
      "address": {
        "@type": "PostalAddress",
        "addressCountry": "GH"
      },
      "sameAs": [
        "https://twitter.com/supplyflow",
        "https://linkedin.com/company/supplyflow"
      ]
    }
  end
  
  def website_structured_data
    {
      "@context": "https://schema.org",
      "@type": "WebSite",
      "name": "SupplyFlow",
      "url": root_url,
      "potentialAction": {
        "@type": "SearchAction",
        "target": {
          "@type": "EntryPoint",
          "urlTemplate": "#{posts_url}?q={search_term_string}"
        },
        "query-input": "required name=search_term_string"
      }
    }
  end
  
  def post_structured_data(post)
    return unless post.present?
    
    base_data = {
      "@context": "https://schema.org",
      "@type": post.schema_type || "Article",
      "headline": post.title,
      "description": post.meta_description || post.excerpt,
      "author": {
        "@type": "Person",
        "name": post.user.name,
        "url": post.user.website_url
      },
      "publisher": {
        "@type": "Organization",
        "name": "SupplyFlow",
        "logo": {
          "@type": "ImageObject",
          "url": og_image_url
        }
      },
      "datePublished": post.published_at&.iso8601,
      "dateModified": post.updated_at.iso8601,
      "mainEntityOfPage": {
        "@type": "WebPage",
        "@id": canonical_url(post_url(post))
      }
    }
    
    # Add image if featured image exists
    if post.featured_image.attached?
      base_data[:image] = {
        "@type": "ImageObject",
        "url": url_for(post.featured_image),
        "width": 1200,
        "height": 630
      }
    end
    
    # Add keywords if present
    if post.keywords.present?
      base_data[:keywords] = post.keywords
    end
    
    # Add categories
    if post.categories.any?
      base_data[:articleSection] = post.categories.pluck(:name).join(", ")
    end
    
    # Add media-specific structured data
    case post.media_type
    when 'video'
      if post.youtube_url.present? || post.vimeo_url.present? || post.video_url.present?
        base_data[:video] = {
          "@type": "VideoObject",
          "name": post.title,
          "description": post.excerpt || post.meta_description,
          "thumbnailUrl": post.thumbnail_url,
          "uploadDate": post.published_at&.iso8601,
          "embedUrl": post.media_metadata&.dig('embed_url') || post.primary_media_url
        }
        
        if post.media_duration.present?
          base_data[:video][:duration] = "PT#{post.media_duration}S"
        end
      end
    when 'audio', 'podcast'
      if post.audio_url.present? || post.podcast_url.present?
        base_data[:audio] = {
          "@type": "AudioObject",
          "name": post.title,
          "description": post.excerpt || post.meta_description,
          "contentUrl": post.audio_url || post.podcast_url
        }
        
        if post.media_duration.present?
          base_data[:audio][:duration] = "PT#{post.media_duration}S"
        end
      end
    end
    
    base_data
  end
  
  def seo_meta_tags(options = {})
    tags = []
    
    # Basic meta tags
    tags << tag(:meta, name: "description", content: meta_description(options[:description]))
    tags << tag(:meta, name: "keywords", content: options[:keywords]) if options[:keywords].present?
    tags << tag(:link, rel: "canonical", href: canonical_url(options[:canonical]))
    
    # Open Graph tags
    tags << tag(:meta, property: "og:title", content: page_title(options[:title]))
    tags << tag(:meta, property: "og:description", content: meta_description(options[:description]))
    tags << tag(:meta, property: "og:image", content: og_image_url(options[:image]))
    tags << tag(:meta, property: "og:url", content: canonical_url(options[:canonical]))
    tags << tag(:meta, property: "og:type", content: options[:og_type] || "website")
    tags << tag(:meta, property: "og:site_name", content: "SupplyFlow")
    
    # Twitter Card tags
    tags << tag(:meta, name: "twitter:card", content: options[:twitter_card] || "summary_large_image")
    tags << tag(:meta, name: "twitter:title", content: page_title(options[:title]))
    tags << tag(:meta, name: "twitter:description", content: meta_description(options[:description]))
    tags << tag(:meta, name: "twitter:image", content: og_image_url(options[:image]))
    
    # Additional meta tags
    tags << tag(:meta, name: "robots", content: options[:robots] || "index, follow")
    
    if options[:author].present?
      tags << tag(:meta, name: "author", content: options[:author])
    end
    
    if options[:published_time].present?
      tags << tag(:meta, property: "article:published_time", content: options[:published_time])
    end
    
    if options[:modified_time].present?
      tags << tag(:meta, property: "article:modified_time", content: options[:modified_time])
    end
    
    if options[:article_tags].present?
      options[:article_tags].each do |article_tag|
        tags << tag(:meta, property: "article:tag", content: article_tag)
      end
    end
    
    safe_join(tags, "\n")
  end
  
  def media_player_embed(post)
    return unless post.has_media?
    
    case post.media_type
    when 'video'
      if post.youtube_url.present?
        youtube_embed(post)
      elsif post.vimeo_url.present?
        vimeo_embed(post)
      elsif post.embed_code.present?
        post.embed_code.html_safe
      elsif post.video_file.attached?
        video_tag post.video_file, controls: true, class: "w-full max-w-4xl mx-auto rounded-lg"
      end
    when 'audio', 'podcast'
      if post.audio_url.present?
        audio_tag post.audio_url, controls: true, class: "w-full max-w-2xl mx-auto"
      elsif post.audio_file.attached?
        audio_tag post.audio_file, controls: true, class: "w-full max-w-2xl mx-auto"
      elsif post.podcast_url.present?
        content_tag :div, class: "podcast-player w-full max-w-2xl mx-auto" do
          link_to "Listen to Podcast", post.podcast_url, target: "_blank", 
                  class: "inline-flex items-center px-6 py-3 bg-primary text-white rounded-lg hover:bg-primary-dark transition-colors"
        end
      end
    end
  end
  
  private
  
  def youtube_embed(post)
    video_id = post.media_metadata&.dig('youtube_id')
    return unless video_id
    
    content_tag :div, class: "relative aspect-w-16 aspect-h-9 max-w-4xl mx-auto" do
      content_tag :iframe,
        nil,
        src: "https://www.youtube.com/embed/#{video_id}",
        title: post.title,
        frameborder: "0",
        allow: "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture",
        allowfullscreen: true,
        class: "absolute inset-0 w-full h-full rounded-lg"
    end
  end
  
  def vimeo_embed(post)
    video_id = post.media_metadata&.dig('vimeo_id')
    return unless video_id
    
    content_tag :div, class: "relative aspect-w-16 aspect-h-9 max-w-4xl mx-auto" do
      content_tag :iframe,
        nil,
        src: "https://player.vimeo.com/video/#{video_id}",
        title: post.title,
        frameborder: "0",
        allow: "autoplay; fullscreen; picture-in-picture",
        allowfullscreen: true,
        class: "absolute inset-0 w-full h-full rounded-lg"
    end
  end
end