import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["bar"]
  
  connect() {
    // Initialize the controller
    this.progress = 0
    this.isAnimating = false
    
    // Add event listeners for Turbo navigation
    document.addEventListener('turbo:before-visit', this.start.bind(this))
    document.addEventListener('turbo:load', this.complete.bind(this))
    document.addEventListener('turbo:before-fetch-response', this.increment.bind(this))
  }
  
  disconnect() {
    // Clean up event listeners
    document.removeEventListener('turbo:before-visit', this.start.bind(this))
    document.removeEventListener('turbo:load', this.complete.bind(this))
    document.removeEventListener('turbo:before-fetch-response', this.increment.bind(this))
  }
  
  start() {
    // Reset progress and show the bar
    this.progress = 0
    this.barTarget.style.width = '0%'
    this.barTarget.classList.remove('opacity-0')
    
    // Start the animation
    this.isAnimating = true
    this.animate()
  }
  
  animate() {
    if (!this.isAnimating) return
    
    // Slowly increment progress until we reach 80%
    if (this.progress < 80) {
      this.progress += (0.1 + Math.random() * 0.3) // Random increment for natural feel
      this.barTarget.style.width = `${this.progress}%`
    }
    
    // Continue animation
    requestAnimationFrame(this.animate.bind(this))
  }
  
  increment() {
    // Jump to 80% when response is received
    this.progress = 80
    this.barTarget.style.width = '80%'
  }
  
  complete() {
    // Complete the progress bar
    this.progress = 100
    this.barTarget.style.width = '100%'
    
    // Stop the animation
    this.isAnimating = false
    
    // Hide the bar after a short delay
    setTimeout(() => {
      this.barTarget.classList.add('opacity-0')
    }, 500)
  }
}
