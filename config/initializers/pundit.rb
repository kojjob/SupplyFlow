# Extends the ApplicationController to add Pundit for authorization.
# https://github.com/varvet/pundit
module PunditHelper
  extend ActiveSupport::Concern

  included do
    include Pundit::Authorization

    # Enforce Pundit authorization in all controllers
    after_action :verify_authorized, except: :index, unless: :skip_pundit?
    after_action :verify_policy_scoped, only: :index, unless: :skip_pundit_or_missing_index?

    # Customize the behavior of Pundit user
    def pundit_user
      {
        user: current_user,
        organization: current_organization
      }
    end

    # Helper method to get current organization
    def current_organization
      current_user&.organization
    end

    # Rescue from Pundit authorization errors
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    private

    def user_not_authorized
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to(request.referrer || root_path)
    end

    def active_storage_controller?
      # List of Active Storage controllers that should skip Pundit checks
      [
        "active_storage/blobs/redirect",
        "active_storage/blobs/proxy",
        "active_storage/representations/redirect",
        "active_storage/representations/proxy",
        "active_storage/disk" # For direct disk service
      ].include?(params[:controller])
    end

    def skip_pundit?
      devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)/ || !user_signed_in? || active_storage_controller?
    end

    def skip_pundit_or_missing_index?
      skip_pundit? || !respond_to?(:index) || active_storage_controller?
    end
  end
end

# Include PunditHelper in ApplicationController when it's loaded
ActiveSupport.on_load(:action_controller) do
  include PunditHelper
end
