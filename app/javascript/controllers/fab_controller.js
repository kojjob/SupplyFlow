import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "button"]

  connect() {
    // Initialize the controller
    this.isOpen = false

    // Close the menu when clicking outside
    document.addEventListener('click', this.handleOutsideClick.bind(this))
  }

  disconnect() {
    // Remove event listener when controller is disconnected
    document.removeEventListener('click', this.handleOutsideClick.bind(this))
  }

  handleOutsideClick(event) {
    // Close the menu if it's open and the click is outside the menu and button
    if (this.isOpen &&
        !this.menuTarget.contains(event.target) &&
        !this.buttonTarget.contains(event.target)) {
      this.close()
    }
  }

  toggle(event) {
    // Prevent the event from bubbling up to document
    if (event) event.stopPropagation()

    if (this.isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.menuTarget.classList.remove("scale-0", "opacity-0", "pointer-events-none")
    this.menuTarget.classList.add("scale-100", "opacity-100", "pointer-events-auto")
    this.buttonTarget.classList.add("rotate-45")
    this.isOpen = true
  }

  close() {
    this.menuTarget.classList.add("scale-0", "opacity-0", "pointer-events-none")
    this.menuTarget.classList.remove("scale-100", "opacity-100", "pointer-events-auto")
    this.buttonTarget.classList.remove("rotate-45")
    this.isOpen = false
  }

  // Open chat widget
  openChat(event) {
    // Prevent default behavior
    event.preventDefault()

    // Close the FAB menu
    this.close()

    // Direct method: Find the chat widget and manipulate it directly
    const chatOverlay = document.querySelector('[data-controller="chat-widget"][data-chat-widget-target="overlay"]')
    if (chatOverlay) {
      // Show overlay
      chatOverlay.classList.remove('hidden')
      
      // Check if we're on mobile or desktop and show appropriate container
      const isMobile = window.innerWidth < 768
      
      if (isMobile) {
        const mobileContainer = chatOverlay.querySelector('[data-chat-widget-target="mobileContainer"]')
        if (mobileContainer) {
          setTimeout(() => {
            mobileContainer.classList.remove("translate-y-full")
            mobileContainer.classList.add("translate-y-0")
          }, 50)
        }
      } else {
        const desktopContainer = chatOverlay.querySelector('[data-chat-widget-target="desktopContainer"]')
        if (desktopContainer) {
          setTimeout(() => {
            desktopContainer.classList.remove("scale-0", "opacity-0")
            desktopContainer.classList.add("scale-100", "opacity-100") 
          }, 50)
        }
      }
      
      console.log("Chat widget opened manually")
    } else {
      console.error("Chat widget overlay not found")
    }
  }

  // Open search overlay
  openSearch(event) {
    // Prevent default behavior
    event.preventDefault()

    // Close the FAB menu
    this.close()

    // Direct method: Find search overlay and manipulate it directly
    const searchOverlay = document.querySelector('[data-controller="search-overlay"][data-search-overlay-target="overlay"]')
    if (searchOverlay) {
      // Show overlay
      searchOverlay.classList.remove('hidden')
      
      // Show container
      const container = searchOverlay.querySelector('[data-search-overlay-target="container"]')
      if (container) {
        setTimeout(() => {
          container.classList.remove('-translate-y-full')
          container.classList.add('translate-y-0')
          
          // Focus the search input
          const input = container.querySelector('[data-search-overlay-target="input"]')
          if (input) input.focus()
        }, 50)
      }
      
      console.log("Search overlay opened manually")
    } else {
      console.error("Search overlay not found")
    }
  }

  // Open contact form
  openContact(event) {
    // Prevent default behavior
    event.preventDefault()

    // Close the FAB menu
    this.close()

    // Direct method: Find contact form and manipulate it directly
    const contactOverlay = document.querySelector('[data-controller="contact-form"][data-contact-form-target="overlay"]')
    if (contactOverlay) {
      // Show overlay
      contactOverlay.classList.remove('hidden')
      
      // Show container
      const container = contactOverlay.querySelector('[data-contact-form-target="container"]')
      if (container) {
        setTimeout(() => {
          container.classList.remove('scale-0', 'opacity-0')
          container.classList.add('scale-100', 'opacity-100')
          
          // Focus the first input
          const input = container.querySelector('#contact-name')
          if (input) input.focus()
        }, 50)
      }
      
      console.log("Contact form opened manually")
    } else {
      console.error("Contact form not found")
    }
  }

  // Product Management Actions
  createProduct(event) {
    event.preventDefault()
    this.close()
    
    // Open the product modal using our helper function
    if (window.ModalHelpers) {
      window.ModalHelpers.showProductModal()
    } else {
      // Fallback if helper isn't available yet
      const modal = document.getElementById("product-modal")
      if (modal) {
        const controller = this.application.getControllerForElementAndIdentifier(modal, 'modal')
        if (controller) {
          controller.openWithData({
            title: "Create New Product",
            action: "/products",
            method: "post",
            submitText: "Create Product"
          })
        }
      }
    }
  }

  // Location Management Actions
  createLocation(event) {
    event.preventDefault()
    this.close()
    
    // Open location modal
    const modal = document.getElementById("location-modal")
    if (modal) {
      const controller = window.Stimulus.getControllerForElementAndIdentifier(modal, 'modal')
      if (controller) {
        controller.openWithData({
          title: "Create New Location",
          action: "/locations",
          method: "post",
          submitText: "Create Location"
        })
      } else {
        // Use ModalHelpers if available (preferred method)
        if (window.ModalHelpers) {
          window.ModalHelpers.showLocationModal()
        } else {
          console.error("Location modal controller not found")
        }
      }
    } else {
      // Use ModalHelpers if available (preferred method)
      if (window.ModalHelpers) {
        window.ModalHelpers.showLocationModal()
      } else {
        console.error("Location modal element not found")
      }
    }
  }

  // Inventory Management Actions
  transferInventory(event) {
    event.preventDefault()
    this.close()
    
    // Simplify by using the new inventory transfer modal directly
    if (window.ModalHelpers) {
      window.ModalHelpers.showInventoryModal()
    } else {
      // Fallback to older approach if needed
      const modal = document.getElementById("inventory-transfer-modal") || document.getElementById("inventory-action-modal")
      if (modal) {
        const controller = window.Stimulus.getControllerForElementAndIdentifier(modal, 'modal')
        if (controller) {
          controller.openWithData({
            title: "Transfer Inventory",
            action: "/inventory/transfer",
            method: "post",
            submitText: "Transfer Stock"
          })
        } else {
          console.error("Inventory modal controller not found")
        }
      } else {
        console.error("Inventory modal element not found")
      }
    }
  }
}
