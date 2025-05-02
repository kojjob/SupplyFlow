class PagesController < ApplicationController
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
end
