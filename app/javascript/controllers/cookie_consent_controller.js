import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["banner"]
  
  connect() {
    // Check if user has already consented
    if (!this.hasConsented()) {
      // Show the banner if no consent has been given
      this.showBanner()
    }
  }
  
  // Check if user has already consented
  hasConsented() {
    return localStorage.getItem('cookieConsent') === 'accepted'
  }
  
  // Show the cookie consent banner
  showBanner() {
    this.bannerTarget.classList.remove('translate-y-full')
    this.bannerTarget.classList.add('translate-y-0')
  }
  
  // Hide the cookie consent banner
  hideBanner() {
    this.bannerTarget.classList.remove('translate-y-0')
    this.bannerTarget.classList.add('translate-y-full')
  }
  
  // Accept cookies
  accept() {
    localStorage.setItem('cookieConsent', 'accepted')
    this.hideBanner()
  }
  
  // Decline cookies
  decline() {
    localStorage.setItem('cookieConsent', 'declined')
    this.hideBanner()
  }
  
  // Open cookie settings
  openSettings() {
    // This would typically open a modal with more detailed cookie settings
    // For now, we'll just accept all cookies
    this.accept()
  }
}
