class AddMultimediaFieldsToPosts < ActiveRecord::Migration[8.0]
  def change
    # Media URLs and embeds
    add_column :posts, :video_url, :string
    add_column :posts, :audio_url, :string
    add_column :posts, :embed_code, :text
    add_column :posts, :media_type, :string, default: 'article'
    add_column :posts, :media_duration, :integer # in seconds
    add_column :posts, :media_thumbnail, :string
    
    # Platform-specific URLs
    add_column :posts, :podcast_url, :string
    add_column :posts, :youtube_url, :string
    add_column :posts, :vimeo_url, :string
    
    # Additional media metadata
    add_column :posts, :media_transcript, :text
    add_column :posts, :media_captions, :jsonb, default: {}
    add_column :posts, :media_metadata, :jsonb, default: {}
    
    # Add index for media type filtering
    add_index :posts, :media_type
  end
end
