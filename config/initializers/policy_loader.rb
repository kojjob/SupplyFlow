# Load all policy concerns explicitly
Rails.application.config.to_prepare do
  # Load policy concerns first
  Dir.glob(Rails.root.join("app", "policies", "concerns", "*.rb")).each do |file|
    require_dependency file
  end

  # Then load regular policies
  Dir.glob(Rails.root.join("app", "policies", "*.rb")).each do |file|
    require_dependency file
  end
end
