import { Controller } from "@hotwired/stimulus"

// Debounce function to limit how often a function can be called
function debounce(func, wait) {
  let timeout;
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
}

export default class extends Controller {
  static targets = ["overlay", "input", "results"]

  connect() {
    // Initialize the controller
    this.isOpen = false
    
    // Bind methods to ensure correct 'this' context
    this.boundHandleKeyDown = this.handleKeyDown.bind(this)
    this.debouncedSearch = debounce(this.performSearch.bind(this), 300)
    
    // Listen for keyboard shortcut (Ctrl+K or Cmd+K)
    document.addEventListener('keydown', this.boundHandleKeyDown)
    
    // Add event listener for input changes if results target exists
    if (this.hasResultsTarget) {
      this.inputTarget.addEventListener('input', this.debouncedSearch)
    }
  }
  
  disconnect() {
    // Clean up event listeners
    document.removeEventListener('keydown', this.boundHandleKeyDown)
    
    if (this.hasResultsTarget) {
      this.inputTarget.removeEventListener('input', this.debouncedSearch)
    }
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
    // Use requestAnimationFrame for better performance
    requestAnimationFrame(() => {
      this.overlayTarget.classList.remove("hidden")
      
      // Force reflow before adding transition classes
      this.overlayTarget.offsetWidth
      
      requestAnimationFrame(() => {
        this.overlayTarget.classList.remove("opacity-0")
        this.inputTarget.focus()
      })
    })
    
    this.isOpen = true
    document.body.classList.add('overflow-hidden') // Prevent background scrolling
  }

  close() {
    this.overlayTarget.classList.add("opacity-0")
    
    // Use transitionend for better performance than setTimeout
    const handleTransitionEnd = () => {
      if (this.isOpen) return // Skip if reopened during transition
      
      this.overlayTarget.classList.add("hidden")
      this.overlayTarget.removeEventListener('transitionend', handleTransitionEnd)
    }
    
    this.overlayTarget.addEventListener('transitionend', handleTransitionEnd)
    
    this.isOpen = false
    document.body.classList.remove('overflow-hidden') // Restore scrolling
    
    // Fallback in case transitionend doesn't fire
    setTimeout(() => {
      if (!this.isOpen && !this.overlayTarget.classList.contains("hidden")) {
        this.overlayTarget.classList.add("hidden")
      }
    }, 350)
  }
  
  // Method to perform search (implemented if results target exists)
  performSearch() {
    // This would be implemented to fetch and display search results
    if (!this.hasResultsTarget) return
    
    const query = this.inputTarget.value.trim()
    
    // Clear results if query is empty
    if (!query) {
      // Logic to clear results
      return
    }
    
    // In a real implementation, this would call an API or search locally
    console.log(`Searching for: ${query}`)
    // this.resultsTarget.innerHTML = 'Searching...'
    
    // Example of fetching search results from server would go here
  }
}
