import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "container", "name", "email", "subject", "message", "submitButton", "success"]

  connect() {
    // Initialize the controller
    this.isOpen = false
  }
  
  open() {
    // Show the overlay
    this.overlayTarget.classList.remove("hidden")
    
    // Animate the container
    setTimeout(() => {
      this.containerTarget.classList.remove("scale-0", "opacity-0")
      this.containerTarget.classList.add("scale-100", "opacity-100")
    }, 50)
    
    this.isOpen = true
    
    // Focus the name field
    setTimeout(() => {
      this.nameTarget.focus()
    }, 500)
  }
  
  close() {
    // Animate the container
    this.containerTarget.classList.remove("scale-100", "opacity-100")
    this.containerTarget.classList.add("scale-0", "opacity-0")
    
    // Hide the overlay after animation
    setTimeout(() => {
      this.overlayTarget.classList.add("hidden")
      
      // Reset the form
      this.resetForm()
    }, 300)
    
    this.isOpen = false
  }
  
  submit(event) {
    event.preventDefault()
    
    // Disable the submit button and show loading state
    this.submitButton.disabled = true
    this.submitButton.innerHTML = '<i class="fas fa-spinner fa-spin mr-2"></i> Sending...'
    
    // Simulate form submission (in a real app, this would be an AJAX request)
    setTimeout(() => {
      // Show success message
      this.successTarget.classList.remove("hidden")
      
      // Reset the form for next time
      this.resetForm()
      
      // Re-enable the submit button
      this.submitButton.disabled = false
      this.submitButton.innerHTML = '<i class="fas fa-paper-plane mr-2"></i> Send Message'
    }, 1500)
  }
  
  resetForm() {
    // Reset form fields
    this.nameTarget.value = ""
    this.emailTarget.value = ""
    this.subjectTarget.value = ""
    this.messageTarget.value = ""
    
    // Hide success message if visible
    this.successTarget.classList.add("hidden")
  }
  
  get submitButton() {
    return this.submitButtonTarget
  }
}
