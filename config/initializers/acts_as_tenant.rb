# Configure ActsAsTenant for multi-tenancy
# https://github.com/ErwinM/acts_as_tenant

# Configuration for ActsAsTenant
# Tenant handling is done in ApplicationController through before_action hooks
ActsAsTenant.configure do |config|
  # Don't require tenant for all models - we'll apply tenant filtering through Pundit
  config.require_tenant = false
end

# This function will be used in models that need tenant association
module ActsAsTenantHelper
  def acts_as_tenant_with_defaults
    acts_as_tenant(:organization)

    # Add default scope to ensure tenant association
    default_scope -> { ActsAsTenant.current_tenant ? where(organization: ActsAsTenant.current_tenant) : all }

    # Validate tenant presence
    validates :organization, presence: true
  end
end

# Make helper available to ActiveRecord
ActiveSupport.on_load(:active_record) do
  extend ActsAsTenantHelper
end
