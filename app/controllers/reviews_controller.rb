class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post
  before_action :set_review, only: %i[edit update destroy]
  after_action :verify_authorized

  # POST /posts/:post_id/reviews
  def create
    @review = @post.reviews.build(review_params)
    @review.user = current_user
    authorize @review

    if @review.save
      redirect_to post_path(@post, anchor: "review_#{@review.id}"), notice: 'Review was successfully created.'
    else
      # It's tricky to render the post show page with review errors directly.
      # Often, this is handled with Turbo Streams or by redirecting back with errors in flash.
      # For simplicity, redirecting back to the post page with an alert.
      # A more robust solution might involve re-rendering the post's show view
      # or using Turbo to update a form section.
      flash[:alert] = @review.errors.full_messages.to_sentence
      redirect_to post_path(@post, anchor: 'review-form')
    end
  end

  # GET /posts/:post_id/reviews/:id/edit
  def edit
    authorize @review
    # Typically, reviews are edited inline or via a modal on the post show page.
    # This action might not be directly used if using Turbo Frames/Streams for editing.
  end

  # PATCH/PUT /posts/:post_id/reviews/:id
  def update
    authorize @review
    if @review.update(review_params)
      redirect_to post_path(@post, anchor: "review_#{@review.id}"), notice: 'Review was successfully updated.'
    else
      # Similar to create, handling errors can be complex.
      # Re-rendering an edit form or using Turbo is common.
      flash[:alert] = @review.errors.full_messages.to_sentence
      redirect_to post_path(@post, anchor: "review_#{@review.id}") # Or an edit path if you have one
    end
  end

  # DELETE /posts/:post_id/reviews/:id
  def destroy
    authorize @review
    @review.destroy
    redirect_to post_path(@post, anchor: 'reviews-section'), notice: 'Review was successfully destroyed.', status: :see_other
  end

  private

  def set_post
    @post = Post.find_by!(slug: params[:post_id]) # Assuming post_id is the slug from nested route
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Post not found."
    redirect_to root_path # Or some other appropriate path
  end

  def set_review
    @review = @post.reviews.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Review not found."
    redirect_to post_path(@post)
  end

  def review_params
    params.require(:review).permit(:body, :rating)
  end
end
