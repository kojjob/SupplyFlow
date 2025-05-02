module ApplicationHelper
  # Determines if the given path is the current page
  # @param path [String] The path to check
  # @param exact [Boolean] Whether to match the path exactly or as a prefix
  # @return [Boolean] True if the current page matches the path
  def active_link?(path, exact: false)
    if exact
      request.path == path
    else
      request.path.start_with?(path)
    end
  end

  # Returns the appropriate CSS classes for an active link
  # @param path [String] The path to check
  # @param exact [Boolean] Whether to match the path exactly or as a prefix
  # @param active_class [String] The CSS class to apply when active
  # @param inactive_class [String] The CSS class to apply when inactive
  # @return [String] The CSS classes to apply
  def active_link_class(path, exact: false, active_class: 'text-white bg-white/10', inactive_class: 'text-gray-100 hover:text-white')
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
    render partial: 'shared/breadcrumbs', locals: { breadcrumbs: breadcrumbs }
  end

  # Helper to generate page title with optional section
  # @param section [String] The section name to prepend to the title
  # @return [String] The formatted page title
  def page_title(section = nil)
    base_title = "SupplyFlow - Streamline Your Supply Chain"
    section.present? ? "#{section} | #{base_title}" : base_title
  end
end
