import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  connect() {
    // Initialize touch tracking variables
    this.touchStartX = 0
    this.touchEndX = 0
    this.touchStartY = 0
    this.touchEndY = 0
    this.minSwipeDistance = 50 // Minimum distance to consider as a swipe
    this.edgeThreshold = 30 // Distance from edge to consider as an edge swipe

    // Add touch event listeners
    this.element.addEventListener('touchstart', this.handleTouchStart.bind(this), { passive: true })
    this.element.addEventListener('touchend', this.handleTouchEnd.bind(this), { passive: false })
  }

  disconnect() {
    // Clean up event listeners
    this.element.removeEventListener('touchstart', this.handleTouchStart.bind(this))
    this.element.removeEventListener('touchend', this.handleTouchEnd.bind(this))
  }

  handleTouchStart(event) {
    // Store the initial touch position
    this.touchStartX = event.changedTouches[0].screenX
    this.touchStartY = event.changedTouches[0].screenY

    // Store window width for edge detection
    this.windowWidth = window.innerWidth
  }

  handleTouchEnd(event) {
    // Store the final touch position
    this.touchEndX = event.changedTouches[0].screenX
    this.touchEndY = event.changedTouches[0].screenY

    // Calculate the horizontal and vertical distance
    const horizontalDistance = this.touchEndX - this.touchStartX
    const verticalDistance = this.touchEndY - this.touchStartY

    // Only consider horizontal swipes where the horizontal movement is greater than vertical
    if (Math.abs(horizontalDistance) > Math.abs(verticalDistance)) {
      // Check if the swipe distance is significant enough
      if (Math.abs(horizontalDistance) > this.minSwipeDistance) {
        // For right swipes, check if it started near the left edge
        if (horizontalDistance > 0 && this.touchStartX < this.edgeThreshold) {
          // Swipe right from left edge - open menu
          this.handleSwipeRight()
        }
        // For left swipes, check if the menu is open (handled by navbar controller)
        else if (horizontalDistance < 0) {
          // Swipe left - close menu if open
          this.handleSwipeLeft()
        }
      }
    }
  }

  handleSwipeRight() {
    // Find the navbar controller to open the mobile menu
    const navbarController = this.application.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller="navbar"]'),
      'navbar'
    )

    if (navbarController && !navbarController.mobileMenuOpen) {
      navbarController.openMobileMenu()

      // Show a toast notification for first-time users
      this.showSwipeHelpToast()
    }
  }

  handleSwipeLeft() {
    // Find the navbar controller to close the mobile menu
    const navbarController = this.application.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller="navbar"]'),
      'navbar'
    )

    if (navbarController && navbarController.mobileMenuOpen) {
      navbarController.closeMobileMenu()
    }
  }

  showSwipeHelpToast() {
    // Only show the toast if it's the first time using swipe gestures
    if (!localStorage.getItem('swipeGestureIntroShown')) {
      // Find the toast controller
      const toastController = this.application.getControllerForElementAndIdentifier(
        document.querySelector('[data-controller="toast"]'),
        'toast'
      )

      if (toastController) {
        toastController.info('Tip: Swipe left to close the menu')
        localStorage.setItem('swipeGestureIntroShown', 'true')
      }
    }
  }
}
