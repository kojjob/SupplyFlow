import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "arrow"]

  connect() {
    // Initialize the controller
    this.isOpen = false
  }

  toggle() {
    if (this.isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    // Remove hidden class
    this.contentTarget.classList.remove('hidden')

    // Get the scrollHeight to use for max-height
    const contentHeight = this.contentTarget.scrollHeight

    // Set max-height to the content's scrollHeight
    this.contentTarget.style.maxHeight = `${contentHeight}px`

    // Rotate arrow icon if it exists
    if (this.hasArrowTarget) {
      this.arrowTarget.classList.add('rotate-180')
    }

    this.isOpen = true
  }

  close() {
    // Set max-height to 0 to collapse
    this.contentTarget.style.maxHeight = '0px'

    // Add hidden class after animation
    setTimeout(() => {
      this.contentTarget.classList.add('hidden')
    }, 300) // Match the duration of the transition

    // Rotate arrow icon back if it exists
    if (this.hasArrowTarget) {
      this.arrowTarget.classList.remove('rotate-180')
    }

    this.isOpen = false
  }
}
