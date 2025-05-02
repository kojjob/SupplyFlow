import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mobileMenu", "menuIcon", "closeIcon"]

  connect() {
    // Initialize the controller
    this.mobileMenuOpen = false
  }

  toggleMobileMenu() {
    if (this.mobileMenuOpen) {
      this.closeMobileMenu()
    } else {
      this.openMobileMenu()
    }
  }

  openMobileMenu() {
    // Show mobile menu
    this.mobileMenuTarget.classList.remove('translate-x-full')
    
    // Toggle icons
    this.menuIconTarget.classList.add('hidden')
    this.closeIconTarget.classList.remove('hidden')
    
    // Prevent body scrolling
    document.body.classList.add('overflow-hidden')
    
    this.mobileMenuOpen = true
  }

  closeMobileMenu() {
    // Hide mobile menu
    this.mobileMenuTarget.classList.add('translate-x-full')
    
    // Toggle icons
    this.menuIconTarget.classList.remove('hidden')
    this.closeIconTarget.classList.add('hidden')
    
    // Re-enable body scrolling
    document.body.classList.remove('overflow-hidden')
    
    this.mobileMenuOpen = false
  }
}
