import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  static targets = ["modal", "overlay", "container", "title", "content", "form", "cancelButton", "submitButton", "errorMessage"]
  static values = {
    size: { type: String, default: "md" }, // sm, md, lg, xl, full
    animation: { type: String, default: "fade" }, // fade, slide, zoom
    submitPath: String,
    resourceType: String,
    closeOnOutsideClick: { type: Boolean, default: true },
    showClose: { type: Boolean, default: true },
    backdrop: { type: Boolean, default: true }
  }

  connect() {
    // Initialize modal
    this.closeOnEscape = this.closeOnEscape.bind(this)
    this.closeOnOutsideClick = this.closeOnOutsideClick.bind(this)
    document.addEventListener("keydown", this.closeOnEscape)
    
    // Apply classes based on modal size
    if (this.hasContainerTarget) {
      const sizeClasses = {
        sm: "max-w-md",
        md: "max-w-lg",
        lg: "max-w-2xl",
        xl: "max-w-4xl",
        full: "max-w-full mx-4"
      }
      
      // Remove any existing size classes
      Object.values(sizeClasses).forEach(cls => {
        this.containerTarget.classList.remove(cls)
      })
      
      // Add the appropriate size class
      const sizeClass = sizeClasses[this.sizeValue] || sizeClasses.md
      this.containerTarget.classList.add(sizeClass)
    }
    
    // Listen for custom events to open this modal
    document.addEventListener("modal:open", (event) => {
      if (event.detail.id === this.element.id) {
        this.openWithData(event.detail.data)
      }
    })
  }

  disconnect() {
    document.removeEventListener("keydown", this.closeOnEscape)
    document.removeEventListener("click", this.closeOnOutsideClick)
  }

  open() {
    // Show modal and add backdrop
    this.modalTarget.classList.remove("hidden")
    
    // Prevent body scrolling
    document.body.classList.add("overflow-hidden")
    
    // Apply animation
    this.animateIn()
    
    // Add outside click handler if enabled
    if (this.closeOnOutsideClickValue) {
      setTimeout(() => {
        document.addEventListener("click", this.closeOnOutsideClick)
      }, 100) // Small delay to prevent the modal from closing immediately
    }
    
    // Dispatch event
    this.dispatch("opened")
  }
  
  openWithData(data) {
    if (!data) {
      this.open()
      return
    }
    
    // Set title if provided and title target exists
    if (data.title && this.hasTitleTarget) {
      this.titleTarget.textContent = data.title
    }
    
    // Set content if provided and content target exists
    if (data.content && this.hasContentTarget) {
      this.contentTarget.innerHTML = data.content
    }
    
    // Set form action if provided and form target exists
    if (data.action && this.hasFormTarget) {
      this.formTarget.action = data.action
    }
    
    // Set resource ID if provided
    if (data.resourceId && this.hasFormTarget) {
      const method = data.method || "post"
      const hiddenMethodField = this.formTarget.querySelector('input[name="_method"]')
      
      if (method !== "post" && !hiddenMethodField) {
        // Create a hidden method field if it doesn't exist
        const input = document.createElement("input")
        input.type = "hidden"
        input.name = "_method"
        input.value = method
        this.formTarget.appendChild(input)
      } else if (hiddenMethodField) {
        hiddenMethodField.value = method
      }
      
      // Add or update resource ID field
      let resourceIdField = this.formTarget.querySelector(`input[name="${this.resourceTypeValue}_id"]`)
      if (!resourceIdField) {
        resourceIdField = document.createElement("input")
        resourceIdField.type = "hidden"
        resourceIdField.name = `${this.resourceTypeValue}_id`
        this.formTarget.appendChild(resourceIdField)
      }
      resourceIdField.value = data.resourceId
    }
    
    // Update submit button text if provided
    if (data.submitText && this.hasSubmitButtonTarget) {
      this.submitButtonTarget.textContent = data.submitText
    }
    
    // Update cancel button text if provided
    if (data.cancelText && this.hasCancelButtonTarget) {
      this.cancelButtonTarget.textContent = data.cancelText
    }
    
    this.open()
  }

  close() {
    // Animate out first
    this.animateOut().then(() => {
      this.modalTarget.classList.add("hidden")
      document.body.classList.remove("overflow-hidden")
      
      // Remove outside click handler
      document.removeEventListener("click", this.closeOnOutsideClick)
      
      // Dispatch event
      this.dispatch("closed")
      
      // Reset form if it exists
      if (this.hasFormTarget) {
        this.formTarget.reset()
      }
      
      // Reset error message if it exists
      if (this.hasErrorMessageTarget) {
        this.errorMessageTarget.textContent = ""
        this.errorMessageTarget.classList.add("hidden")
      }
    })
  }

  closeOnEscape(event) {
    if (event.key === "Escape" && !this.modalTarget.classList.contains("hidden")) {
      this.close()
    }
  }
  
  closeOnOutsideClick(event) {
    // Check if the click was outside the modal container
    const container = this.hasContainerTarget ? this.containerTarget : this.modalTarget.querySelector(".modal-container")
    
    if (container && !container.contains(event.target) && this.modalTarget.contains(event.target)) {
      this.close()
    }
  }
  
  // Animation methods
  animateIn() {
    if (this.hasContainerTarget) {
      // Apply different animation based on type
      switch (this.animationValue) {
        case "slide":
          this.containerTarget.classList.add("transform", "transition-transform", "duration-300", "ease-out")
          this.containerTarget.classList.remove("translate-y-full")
          this.containerTarget.classList.add("translate-y-0")
          break
          
        case "zoom":
          this.containerTarget.classList.add("transform", "transition-all", "duration-300", "ease-out")
          this.containerTarget.classList.remove("scale-95", "opacity-0")
          this.containerTarget.classList.add("scale-100", "opacity-100")
          break
          
        case "fade":
        default:
          this.containerTarget.classList.add("transition-opacity", "duration-300", "ease-out")
          this.containerTarget.classList.remove("opacity-0")
          this.containerTarget.classList.add("opacity-100")
          break
      }
      
      // Add overlay fade in if backdrop is enabled
      if (this.backdropValue && this.hasOverlayTarget) {
        this.overlayTarget.classList.add("transition-opacity", "duration-300", "ease-out")
        this.overlayTarget.classList.remove("opacity-0")
        this.overlayTarget.classList.add("opacity-100")
      }
    }
  }
  
  animateOut() {
    return new Promise(resolve => {
      if (this.hasContainerTarget) {
        // Apply different animation based on type
        switch (this.animationValue) {
          case "slide":
            this.containerTarget.classList.remove("translate-y-0")
            this.containerTarget.classList.add("translate-y-full")
            break
            
          case "zoom":
            this.containerTarget.classList.remove("scale-100", "opacity-100")
            this.containerTarget.classList.add("scale-95", "opacity-0")
            break
            
          case "fade":
          default:
            this.containerTarget.classList.remove("opacity-100")
            this.containerTarget.classList.add("opacity-0")
            break
        }
        
        // Add overlay fade out if backdrop is enabled
        if (this.backdropValue && this.hasOverlayTarget) {
          this.overlayTarget.classList.remove("opacity-100")
          this.overlayTarget.classList.add("opacity-0")
        }
        
        // Wait for animation to complete
        setTimeout(resolve, 300)
      } else {
        resolve()
      }
    })
  }

  submitForm(event) {
    event.preventDefault()
    const form = event.target
    const url = form.action
    const formData = new FormData(form)
    const errorMessageElement = this.hasErrorMessageTarget ? this.errorMessageTarget : form.querySelector(".error-message")

    // Clear previous error messages
    if (errorMessageElement) {
      errorMessageElement.textContent = ""
      errorMessageElement.classList.add("hidden")
    }

    // Show loading state
    const submitButton = this.hasSubmitButtonTarget ? this.submitButtonTarget : form.querySelector('button[type="submit"]')
    const originalButtonText = submitButton.innerHTML
    submitButton.disabled = true
    submitButton.innerHTML = '<i class="fas fa-spinner fa-spin mr-2"></i> Processing...'

    fetch(url, {
      method: form.method || "POST",
      body: formData,
      headers: {
        "Accept": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        // Dispatch success event with the data
        this.dispatch("success", { detail: data })
        
        // Reset the form
        form.reset()

        // Close the modal
        this.close()

        // Show success message
        this.showToast(data.message || `${this.resourceTypeValue} processed successfully!`, "success")
      } else {
        // Show error message
        if (errorMessageElement) {
          errorMessageElement.textContent = data.errors ? data.errors.join(", ") : "An error occurred"
          errorMessageElement.classList.remove("hidden")
        }

        // Reset button state
        submitButton.disabled = false
        submitButton.innerHTML = originalButtonText
        
        // Dispatch error event
        this.dispatch("error", { detail: data })
      }
    })
    .catch(error => {
      console.error("Error:", error)
      
      if (errorMessageElement) {
        errorMessageElement.textContent = "An error occurred. Please try again."
        errorMessageElement.classList.remove("hidden")
      }

      // Reset button state
      submitButton.disabled = false
      submitButton.innerHTML = originalButtonText
      
      // Dispatch error event
      this.dispatch("error", { detail: { error: error.message } })
    })
  }

  showToast(message, type = "info") {
    const event = new CustomEvent("toast:show", {
      detail: { message, type }
    })
    document.dispatchEvent(event)
  }
  
  // Helper method to open a modal from another controller
  static open(id, data = {}) {
    document.dispatchEvent(new CustomEvent("modal:open", { 
      detail: { id, data } 
    }))
  }
}
