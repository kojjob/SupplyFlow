import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dropdown", "button", "selected"]
  
  connect() {
    // Initialize the controller
    this.isOpen = false
    
    // Set the current language from localStorage or default to English
    this.currentLanguage = localStorage.getItem('language') || 'en'
    this.updateSelectedLanguage()
  }
  
  toggle(event) {
    event.stopPropagation()
    if (this.isOpen) {
      this.hide()
    } else {
      this.show()
    }
  }
  
  show() {
    // Show dropdown menu
    this.dropdownTarget.classList.remove('scale-95', 'opacity-0', 'invisible')
    this.dropdownTarget.classList.add('scale-100', 'opacity-100')
    
    // Update ARIA attributes
    this.buttonTarget.setAttribute('aria-expanded', 'true')
    
    this.isOpen = true
  }
  
  hide(event) {
    // Don't hide if the click was on the button
    if (event && this.buttonTarget.contains(event.target)) {
      return
    }
    
    // Hide dropdown menu
    this.dropdownTarget.classList.add('scale-95', 'opacity-0', 'invisible')
    this.dropdownTarget.classList.remove('scale-100', 'opacity-100')
    
    // Update ARIA attributes
    this.buttonTarget.setAttribute('aria-expanded', 'false')
    
    this.isOpen = false
  }
  
  selectLanguage(event) {
    event.preventDefault()
    
    // Get the selected language code
    const language = event.currentTarget.dataset.language
    
    // Store the selected language
    localStorage.setItem('language', language)
    this.currentLanguage = language
    
    // Update the UI
    this.updateSelectedLanguage()
    
    // Hide the dropdown
    this.hide()
    
    // In a real application, you would reload the page or update the UI with the new language
    // For now, we'll just show a toast notification
    const toastController = this.application.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller="toast"]'),
      'toast'
    )
    
    if (toastController) {
      toastController.success(`Language changed to ${event.currentTarget.textContent}`)
    }
  }
  
  updateSelectedLanguage() {
    // Update the selected language text
    const languages = {
      'en': 'English',
      'es': 'Español',
      'fr': 'Français',
      'de': 'Deutsch',
      'zh': '中文'
    }
    
    this.selectedTarget.textContent = languages[this.currentLanguage] || 'English'
  }
}
