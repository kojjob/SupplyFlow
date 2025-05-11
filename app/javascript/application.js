// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import * as ModalHelpers from "modal_helpers"

// Make the Stimulus application and ModalHelpers available globally
document.addEventListener("DOMContentLoaded", function() {
  // First, ensure ModalHelpers is exported globally
  window.ModalHelpers = ModalHelpers;
  
  // Fix Stimulus controller access
  // Wait a short time to make sure Stimulus is fully initialized
  setTimeout(() => {
    // Export a fixed getControllerForElementAndIdentifier function
    window.Stimulus = window.Stimulus || {};
    
    // This is the key function that was broken
    window.Stimulus.getControllerForElementAndIdentifier = function(element, identifier) {
      if (!element || !identifier) return null;
      
      // Check if element has the controller
      const controller = element.getAttribute("data-controller");
      if (!controller || !controller.includes(identifier)) {
        return null;
      }
      
      // Access the controller using the Stimulus API
      try {
        // Direct access via Stimulus
        return window.Stimulus.controllers.find(
          controller => controller.element === element && controller.identifier === identifier
        );
      } catch (e) {
        console.error("Error getting controller:", e);
        return null;
      }
    };
    
    // Log success message
    console.log("Stimulus helpers successfully initialized");
  }, 200); // Short delay to ensure Stimulus is ready
});
import "channels"
