module ApplicationHelper
  # Returns the current organization from Current.organization or ActsAsTenant.current_tenant
  # @return [Organization] The current organization
  def current_organization
    Current.organization || ActsAsTenant.current_tenant
  end

  # Determines if the given path is the current page
  # @param path [String, Array<String>] The path or paths to check
  # @param exact [Boolean] Whether to match the path exactly or as a prefix
  # @return [Boolean] True if the current page matches any of the paths
  def active_link?(path, exact: false)
    paths = Array(path)

    paths.any? do |single_path|
      if exact
        request.path == single_path
      else
        request.path.start_with?(single_path)
      end
    end
  end

  # Returns the appropriate CSS classes for an active link
  # @param path [String, Array<String>] The path or paths to check
  # @param exact [Boolean] Whether to match the path exactly or as a prefix
  # @param active_class [String] The CSS class to apply when active
  # @param inactive_class [String] The CSS class to apply when inactive
  # @return [String] The CSS classes to apply
  def active_link_class(path, exact: false, active_class: "text-white bg-white/10", inactive_class: "text-gray-100 hover:text-white")
    if active_link?(path, exact: exact)
      active_class
    else
      inactive_class
    end
  end

  # Generates breadcrumbs for the current page
  # @param breadcrumbs [Array<Hash>] An array of breadcrumb items, each with :title and :url keys
  # @return [String] The rendered breadcrumbs partial
  def render_breadcrumbs(breadcrumbs)
    render partial: "shared/breadcrumbs", locals: { breadcrumbs: breadcrumbs }
  end

  # Helper to generate page title with optional section
  # @param section [String] The section name to prepend to the title
  # @return [String] The formatted page title
  def page_title(section = nil)
    base_title = "SupplyFlow - Streamline Your Supply Chain"
    section.present? ? "#{section} | #{base_title}" : base_title
  end

  # Convert Rails flash types to toast types
  def flash_to_toast_type(flash_type)
    case flash_type.to_sym
    when :notice, :success
      "success"
    when :alert, :error
      "error"
    when :warning
      "warning"
    else
      "info"
    end
  end

  # Prepare flash messages for the toast controller
  def prepare_flash_messages
    return {} if flash.empty?

    # Convert flash messages to a format suitable for the toast controller
    flash_data = {}
    flash.each do |type, message|
      flash_data[flash_to_toast_type(type)] = message
    end

    # Encode as JSON for data attribute
    flash_data.to_json
  end

  # Generate data attribute for flash messages
  def flash_messages_data_attribute
    return {} unless flash.any?

    {
      data: {
        flash_messages: prepare_flash_messages
      }
    }
  end

  # Returns the appropriate CSS classes for a user role badge
  # @param role [String] The user role
  # @return [String] The CSS classes to apply
  def role_badge_class(role)
    base_classes = "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"

    case role
    when "owner"
      "#{base_classes} bg-purple-100 text-purple-800 dark:bg-purple-900 dark:text-purple-200"
    when "admin"
      "#{base_classes} bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200"
    when "manager"
      "#{base_classes} bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200"
    when "staff"
      "#{base_classes} bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200"
    when "viewer"
      "#{base_classes} bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-200"
    else
      "#{base_classes} bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-200"
    end
  end
end
