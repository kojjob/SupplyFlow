# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

# Custom JavaScript modules
pin "modal_helpers", to: "modal_helpers.js"
pin "theme_init"

# Chart libraries
pin "apexcharts", to: "https://cdn.jsdelivr.net/npm/apexcharts@3.37.1/dist/apexcharts.min.js"
pin "@rails/actioncable", to: "actioncable.esm.js"
pin_all_from "app/javascript/channels", under: "channels"
