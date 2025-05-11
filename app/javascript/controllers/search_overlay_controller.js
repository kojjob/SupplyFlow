import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "container", "input", "results", "resultsTitle", "resultsContainer", "noResults"]

  connect() {
    // Initialize the controller
    this.isOpen = false
    
    // Listen for escape key to close the search overlay
    document.addEventListener('keydown', this.handleKeyDown.bind(this))
  }
  
  disconnect() {
    // Remove event listener when controller is disconnected
    document.removeEventListener('keydown', this.handleKeyDown.bind(this))
  }
  
  handleKeyDown(event) {
    // Close the search overlay when escape key is pressed
    if (event.key === 'Escape' && this.isOpen) {
      this.close()
    }
  }
  
  open() {
    // Show the overlay
    this.overlayTarget.classList.remove("hidden")
    
    // Animate the container
    setTimeout(() => {
      this.containerTarget.classList.remove("-translate-y-full")
      this.containerTarget.classList.add("translate-y-0")
    }, 50)
    
    this.isOpen = true
    
    // Focus the input field
    setTimeout(() => {
      this.inputTarget.focus()
    }, 500)
    
    // Prevent scrolling on the body
    document.body.style.overflow = 'hidden'
  }
  
  close() {
    // Animate the container
    this.containerTarget.classList.remove("translate-y-0")
    this.containerTarget.classList.add("-translate-y-full")
    
    // Hide the overlay after animation
    setTimeout(() => {
      this.overlayTarget.classList.add("hidden")
      
      // Reset the search
      this.resetSearch()
    }, 300)
    
    this.isOpen = false
    
    // Re-enable scrolling on the body
    document.body.style.overflow = ''
  }
  
  search(event) {
    event.preventDefault()
    
    const searchTerm = this.inputTarget.value.trim()
    if (!searchTerm) return
    
    // Show the results section
    this.resultsTarget.classList.remove("hidden")
    this.noResultsTarget.classList.add("hidden")
    
    // Update the results title
    this.resultsTitleTarget.textContent = `Search Results for "${searchTerm}"`
    
    // Simulate search (in a real app, this would be an AJAX request)
    setTimeout(() => {
      // For demo purposes, show results for specific search terms
      if (this.hasMatchingResults(searchTerm)) {
        this.showResults(searchTerm)
      } else {
        this.showNoResults()
      }
    }, 1000)
  }
  
  quickSearch(event) {
    const searchTerm = event.currentTarget.dataset.term
    
    // Set the input value
    this.inputTarget.value = searchTerm
    
    // Trigger the search
    this.search(new Event('submit'))
  }
  
  hasMatchingResults(searchTerm) {
    // For demo purposes, return true for specific search terms
    const popularTerms = [
      'inventory', 'stock', 'mobile money', 'offline', 'reports', 'sales', 'alerts'
    ]
    
    return popularTerms.some(term => searchTerm.toLowerCase().includes(term))
  }
  
  showResults(searchTerm) {
    // Generate mock results based on the search term
    let resultsHTML = ''
    
    if (searchTerm.toLowerCase().includes('inventory') || searchTerm.toLowerCase().includes('stock')) {
      resultsHTML += this.createResultItem(
        'Inventory Management',
        'Learn how to track and manage your inventory efficiently.',
        '/features/inventory'
      )
      resultsHTML += this.createResultItem(
        'Setting Up Stock Alerts',
        'Configure automatic notifications when stock levels are low.',
        '/help/stock-alerts'
      )
      resultsHTML += this.createResultItem(
        'Inventory Reports',
        'Generate detailed reports about your inventory status and movement.',
        '/features/reports'
      )
    }
    
    if (searchTerm.toLowerCase().includes('mobile') || searchTerm.toLowerCase().includes('money')) {
      resultsHTML += this.createResultItem(
        'Mobile Money Integration',
        'Accept payments via MTN Mobile Money, Vodafone Cash, and AirtelTigo Money.',
        '/features/payments'
      )
      resultsHTML += this.createResultItem(
        'Setting Up Mobile Money',
        'Step-by-step guide to configure mobile money in your account.',
        '/help/mobile-money-setup'
      )
    }
    
    if (searchTerm.toLowerCase().includes('offline')) {
      resultsHTML += this.createResultItem(
        'Offline Mode',
        'Continue using SupplyFlow even without internet connection.',
        '/features/offline'
      )
      resultsHTML += this.createResultItem(
        'Syncing Offline Data',
        'How to synchronize data when you regain internet connection.',
        '/help/offline-sync'
      )
    }
    
    if (searchTerm.toLowerCase().includes('reports') || searchTerm.toLowerCase().includes('sales')) {
      resultsHTML += this.createResultItem(
        'Sales Reports',
        'Generate and analyze reports on your sales performance.',
        '/features/sales-reports'
      )
      resultsHTML += this.createResultItem(
        'Exporting Reports',
        'Export your reports to Excel, PDF, or CSV formats.',
        '/help/export-reports'
      )
    }
    
    if (searchTerm.toLowerCase().includes('alerts')) {
      resultsHTML += this.createResultItem(
        'Low Stock Alerts',
        'Get notified when your inventory items reach low stock levels.',
        '/features/alerts'
      )
      resultsHTML += this.createResultItem(
        'Customizing Alert Thresholds',
        'Set custom thresholds for different products.',
        '/help/alert-settings'
      )
    }
    
    // If we have results, show them
    if (resultsHTML) {
      this.resultsContainerTarget.innerHTML = resultsHTML
      this.resultsTarget.classList.remove("hidden")
      this.noResultsTarget.classList.add("hidden")
    } else {
      this.showNoResults()
    }
  }
  
  createResultItem(title, description, url) {
    return `
      <a href="${url}" class="block p-4 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors duration-200">
        <h4 class="text-lg font-medium text-[#0055A4] dark:text-[#1A6FBF] mb-1">${title}</h4>
        <p class="text-gray-600 dark:text-gray-400">${description}</p>
        <div class="flex items-center mt-2 text-sm text-[#00A86B]">
          <span>Learn more</span>
          <i class="fas fa-arrow-right ml-1 text-xs"></i>
        </div>
      </a>
    `
  }
  
  showNoResults() {
    this.resultsTarget.classList.add("hidden")
    this.noResultsTarget.classList.remove("hidden")
  }
  
  resetSearch() {
    // Clear the input
    this.inputTarget.value = ""
    
    // Hide results
    this.resultsTarget.classList.add("hidden")
    this.noResultsTarget.classList.add("hidden")
  }
}
