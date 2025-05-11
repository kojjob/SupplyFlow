class PostsController < ApplicationController
  # Skip pundit authorization for the index action
  skip_after_action :verify_authorized, only: [ :index ]
  skip_after_action :verify_policy_scoped, only: [ :index ]

  def index
    # @posts = Post.all
    # render template: "posts/index"
  end
end
