class SitemapsController < ApplicationController
  before_action :set_format_xml
  
  def index
    @posts = Post.published.indexable.includes(:categories, :tags, featured_image_attachment: :blob)
    @categories = Category.with_posts
    @tags = Tag.with_posts
    
    respond_to do |format|
      format.xml
    end
  end
  
  def posts
    @posts = Post.published.indexable.includes(:categories, :tags, featured_image_attachment: :blob)
    
    respond_to do |format|
      format.xml
    end
  end
  
  def categories
    @categories = Category.with_posts
    
    respond_to do |format|
      format.xml
    end
  end
  
  def images
    @posts_with_images = Post.published
                            .indexable
                            .joins(:featured_image_attachment)
                            .includes(featured_image_attachment: :blob)
    
    respond_to do |format|
      format.xml
    end
  end
  
  def main
    @posts = Post.published.indexable.limit(10)
    
    respond_to do |format|
      format.xml
    end
  end
  
  private
  
  def set_format_xml
    request.format = :xml
  end
end
