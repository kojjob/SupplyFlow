import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "button", "arrow"]

  connect() {
    // Initialize the controller
    this.isOpen = false
    this.menuItems = []
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
    this.menuTarget.classList.remove('scale-95', 'opacity-0', 'invisible')
    this.menuTarget.classList.add('scale-100', 'opacity-100')

    // Update ARIA attributes
    this.buttonTarget.setAttribute('aria-expanded', 'true')

    // Rotate arrow icon if it exists
    if (this.hasArrowTarget) {
      this.arrowTarget.classList.add('rotate-180')
    }

    // Cache menu items for keyboard navigation
    this.menuItems = Array.from(this.menuTarget.querySelectorAll('[role="menuitem"]'))

    // Focus the first menu item
    if (this.menuItems.length > 0) {
      setTimeout(() => {
        this.menuItems[0].focus()
      }, 100)
    }

    this.isOpen = true
  }

  hide(event) {
    // Don't hide if the click was on the button or inside the menu
    if (event && (this.buttonTarget.contains(event.target) || this.menuTarget.contains(event.target))) {
      return
    }

    // Hide dropdown menu
    this.menuTarget.classList.add('scale-95', 'opacity-0', 'invisible')
    this.menuTarget.classList.remove('scale-100', 'opacity-100')

    // Update ARIA attributes
    this.buttonTarget.setAttribute('aria-expanded', 'false')

    // Rotate arrow icon back if it exists
    if (this.hasArrowTarget) {
      this.arrowTarget.classList.remove('rotate-180')
    }

    // Return focus to the button when closing
    if (this.isOpen) {
      this.buttonTarget.focus()
    }

    this.isOpen = false
  }

  handleKeydown(event) {
    if (!this.isOpen) {
      // Open menu on arrow down when button is focused
      if (event.key === 'ArrowDown' || event.key === 'Down') {
        event.preventDefault()
        this.show()
      }
      return
    }

    // Handle keyboard navigation within the menu
    switch (event.key) {
      case 'Escape':
        event.preventDefault()
        this.hide()
        break

      case 'ArrowDown':
      case 'Down':
        event.preventDefault()
        this.focusNextMenuItem()
        break

      case 'ArrowUp':
      case 'Up':
        event.preventDefault()
        this.focusPreviousMenuItem()
        break

      case 'Home':
      case 'PageUp':
        event.preventDefault()
        this.focusFirstMenuItem()
        break

      case 'End':
      case 'PageDown':
        event.preventDefault()
        this.focusLastMenuItem()
        break

      case 'Tab':
        // Close the menu when tabbing out
        this.hide()
        break
    }
  }

  // Helper methods for keyboard navigation
  focusNextMenuItem() {
    if (this.menuItems.length === 0) return

    const currentIndex = this.menuItems.indexOf(document.activeElement)
    const nextIndex = currentIndex === this.menuItems.length - 1 ? 0 : currentIndex + 1
    this.menuItems[nextIndex].focus()
  }

  focusPreviousMenuItem() {
    if (this.menuItems.length === 0) return

    const currentIndex = this.menuItems.indexOf(document.activeElement)
    const prevIndex = currentIndex <= 0 ? this.menuItems.length - 1 : currentIndex - 1
    this.menuItems[prevIndex].focus()
  }

  focusFirstMenuItem() {
    if (this.menuItems.length > 0) {
      this.menuItems[0].focus()
    }
  }

  focusLastMenuItem() {
    if (this.menuItems.length > 0) {
      this.menuItems[this.menuItems.length - 1].focus()
    }
  }
}
