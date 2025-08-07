class PostsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_post, only: %i[show edit update destroy publish archive]
  after_action :verify_authorized, except: %i[index] # Public can view index
  after_action :verify_policy_scoped, only: :index

  # GET /posts
  def index
    @posts = policy_scope(Post.published.includes(:user, :rich_text_content, featured_image_attachment: :blob).order(published_at: :desc))
    # Eager load common associations to prevent N+1 queries
  end

  # GET /posts/1
  def show
    # @post is set by set_post
    # Ensure only published posts are publicly viewable unless user is admin/author
    # For public show, we might not need to authorize if it's a published post.
    # However, if drafts/archived posts have the same URL structure, authorization is needed.
    # Assuming PostPolicy#show? handles this logic.
    authorize @post
    @reviews = @post.reviews.includes(:user).order(created_at: :desc) # For displaying reviews
    @review = @post.reviews.build # For new review form
  end

  # GET /posts/new
  def new
    @post = current_user.posts.build
    authorize @post
  end

  # GET /posts/1/edit
  def edit
    authorize @post
  end

  # POST /posts
  def create
    @post = current_user.posts.build(post_params)
    authorize @post

    if @post.save
      redirect_to @post, notice: "Post was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /posts/1
  def update
    authorize @post
    if @post.update(post_params)
      redirect_to @post, notice: "Post was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /posts/1
  def destroy
    authorize @post
    @post.destroy
    redirect_to posts_url, notice: "Post was successfully destroyed.", status: :see_other
  end

  # PATCH /posts/1/publish
  def publish
    authorize @post
    if @post.update(status: :published, published_at: Time.current)
      redirect_to @post, notice: "Post was successfully published."
    else
      redirect_to @post, alert: "Failed to publish post."
    end
  end

  # PATCH /posts/1/archive
  def archive
    authorize @post
    if @post.update(status: :archived)
      redirect_to @post, notice: "Post was successfully archived."
    else
      redirect_to @post, alert: "Failed to archive post."
    end
  end

  private

  def set_post
    @post = Post.find_by!(slug: params[:slug])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Post not found."
    redirect_to posts_path
  end

  def post_params
    params.require(:post).permit(
      :title,
      :content,
      :published_at,
      :slug,
      :status,
      :meta_title,
      :meta_description,
      :excerpt,
      :keywords,
      :canonical_url,
      :og_image,
      :twitter_image,
      :no_index,
      :schema_type,
      :focus_keyword,
      :featured_image,
      :video_file,
      :audio_file,
      :video_url,
      :audio_url,
      :embed_code,
      :media_type,
      :media_duration,
      :media_thumbnail,
      :podcast_url,
      :youtube_url,
      :vimeo_url,
      :media_transcript,
      :media_captions,
      :media_metadata,
      category_ids: [],
      tag_ids: [],
      media_files: []
    )
  end
end
