class PagesController < ApplicationController
  # Skip pundit authorization for all pages controller actions
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def index
    # This action is needed for Pundit policy scope verification
    # It's not actually used in the application
  end

  def offline
    # Render the offline page
    render :offline
  end

  def swipe_test
    # Render the swipe test page
    render :swipe_test
  end

  def about
    # Render the about page
    render :about
  end

  def contact
    # Render the contact page
    render :contact
  end

  def support
    # Render the support page
    render :support
  end

  def setup_guide
    # Define the steps for the setup guide
    @steps = [
      "Configure Organization",
      "Set Up Locations",
      "Add Products",
      "Record Initial Stock",
      "Invite Team"
    ]
    # Determine the current step (e.g., based on user progress or params)
    # For now, let's default to the first step or get it from params
    @current_step = params[:step].present? ? params[:step].to_i - 1 : 0
    @current_step = @steps.size - 1 if @current_step >= @steps.size # Cap at max step
    @current_step = 0 if @current_step < 0 # Ensure non-negative

    # Render the setup guide page
    render :setup_guide
  end

  def documentation
    # Render the documentation page
    render :documentation
  end
end
