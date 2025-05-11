module Rails
  class PwaController < ApplicationController
    def manifest
      render
    end

    def service_worker
      skip_authorization
      # Set appropriate headers for service worker
      headers["Cache-Control"] = "max-age=0"
      headers["Content-Type"] = "application/javascript"

      # Render the service worker JavaScript
      render file: Rails.root.join("app", "javascript", "service_worker.js")
    end
  end
end
