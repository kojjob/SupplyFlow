import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "input"]

  connect() {
    // Initialize the controller
    this.isOpen = false
    
    // Listen for keyboard shortcut (Ctrl+K or Cmd+K)
    document.addEventListener('keydown', this.handleKeyDown.bind(this))
  }
  
  disconnect() {
    document.removeEventListener('keydown', this.handleKeyDown.bind(this))
  }
  
  handleKeyDown(event) {
    // Check for Ctrl+K or Cmd+K
    if ((event.ctrlKey || event.metaKey) && event.key === 'k') {
      event.preventDefault()
      this.toggle()
    }
    
    // Close on Escape key
    if (this.isOpen && event.key === 'Escape') {
      this.close()
    }
  }

  toggle() {
    if (this.isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.overlayTarget.classList.remove("hidden")
    setTimeout(() => {
      this.overlayTarget.classList.remove("opacity-0")
      this.inputTarget.focus()
    }, 50)
    this.isOpen = true
  }

  close() {
    this.overlayTarget.classList.add("opacity-0")
    setTimeout(() => {
      this.overlayTarget.classList.add("hidden")
    }, 300)
    this.isOpen = false
  }
}
