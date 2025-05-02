import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]
  
  connect() {
    // Set initial state
    this.buttonTarget.classList.add('hidden')
    
    // Add scroll event listener
    window.addEventListener('scroll', this.handleScroll.bind(this))
  }
  
  disconnect() {
    // Clean up event listener
    window.removeEventListener('scroll', this.handleScroll.bind(this))
  }
  
  handleScroll() {
    // Show button when scrolled down 300px, hide otherwise
    if (window.scrollY > 300) {
      this.showButton()
    } else {
      this.hideButton()
    }
  }
  
  showButton() {
    if (this.buttonTarget.classList.contains('hidden')) {
      this.buttonTarget.classList.remove('hidden')
      // Use setTimeout to add the opacity transition after the display is set
      setTimeout(() => {
        this.buttonTarget.classList.remove('opacity-0')
        this.buttonTarget.classList.add('opacity-100')
      }, 10)
    }
  }
  
  hideButton() {
    if (!this.buttonTarget.classList.contains('hidden')) {
      this.buttonTarget.classList.remove('opacity-100')
      this.buttonTarget.classList.add('opacity-0')
      // Wait for transition to complete before hiding
      setTimeout(() => {
        this.buttonTarget.classList.add('hidden')
      }, 300)
    }
  }
  
  scrollToTop(event) {
    event.preventDefault()
    
    // Smooth scroll to top
    window.scrollTo({
      top: 0,
      behavior: 'smooth'
    })
  }
}
