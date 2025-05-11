import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["quantityField", "stockLevel", "availableStock", "actionLabel", "productName", "locationName", "errorMessage"]
  static values = {
    productId: Number,
    locationId: Number,
    inventoryId: Number
  }

  connect() {
    // Initialize controller
    this.fetchInventoryData()
    
    // Set up listeners
    if (this.hasQuantityFieldTarget) {
      this.quantityFieldTarget.addEventListener('input', this.validateQuantity.bind(this))
    }
  }
  
  // API Methods
  
  fetchInventoryData() {
    // Check if we have both product and location IDs
    if (!this.productIdValue || !this.locationIdValue) return
    
    // Show loading state
    this.setLoadingState(true)
    
    // Fetch inventory data from API
    fetch(`/api/v1/inventory?product_id=${this.productIdValue}&location_id=${this.locationIdValue}`)
      .then(response => response.json())
      .then(data => {
        this.updateInventoryDisplay(data)
        this.setLoadingState(false)
      })
      .catch(error => {
        console.error("Error fetching inventory data:", error)
        this.showError("Error loading inventory data. Please try again.")
        this.setLoadingState(false)
      })
  }
  
  addStock(event) {
    event.preventDefault()
    
    // Get form data
    const quantity = parseInt(this.quantityFieldTarget.value, 10)
    const notes = document.getElementById('inventory_notes').value
    
    // Validate quantity
    if (!quantity || quantity <= 0) {
      this.showError("Please enter a valid quantity")
      return
    }
    
    // Show loading state
    this.setLoadingState(true)
    
    // Send add stock request
    fetch('/api/v1/inventory', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector("meta[name='csrf-token']").content
      },
      body: JSON.stringify({
        product_id: this.productIdValue,
        location_id: this.locationIdValue,
        quantity: quantity,
        notes: notes
      })
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        // Show success message
        this.showToast(data.message, "success")
        
        // Update inventory display
        this.updateInventoryItem(data.inventory_item)
        
        // Clear form
        this.quantityFieldTarget.value = ""
        document.getElementById('inventory_notes').value = ""
      } else {
        // Show error message
        this.showError(data.errors.join(", "))
      }
      this.setLoadingState(false)
    })
    .catch(error => {
      console.error("Error adding stock:", error)
      this.showError("Error adding stock. Please try again.")
      this.setLoadingState(false)
    })
  }
  
  removeStock(event) {
    event.preventDefault()
    
    // Get form data
    const quantity = parseInt(this.quantityFieldTarget.value, 10)
    const notes = document.getElementById('inventory_notes').value
    
    // Validate quantity
    if (!quantity || quantity <= 0) {
      this.showError("Please enter a valid quantity")
      return
    }
    
    // Check if we have enough stock
    const availableStock = parseInt(this.availableStockTarget.textContent, 10)
    if (quantity > availableStock) {
      this.showError(`Cannot remove more than available quantity (${availableStock})`)
      return
    }
    
    // Show loading state
    this.setLoadingState(true)
    
    // Send remove stock request
    fetch(`/api/v1/inventory/${this.inventoryIdValue}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector("meta[name='csrf-token']").content
      },
      body: JSON.stringify({
        action_type: 'remove',
        quantity: quantity,
        notes: notes
      })
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        // Show success message
        this.showToast(data.message, "success")
        
        // Update inventory display
        this.updateInventoryItem(data.inventory_item)
        
        // Clear form
        this.quantityFieldTarget.value = ""
        document.getElementById('inventory_notes').value = ""
      } else {
        // Show error message
        this.showError(data.errors.join(", "))
      }
      this.setLoadingState(false)
    })
    .catch(error => {
      console.error("Error removing stock:", error)
      this.showError("Error removing stock. Please try again.")
      this.setLoadingState(false)
    })
  }
  
  transferStock(event) {
    event.preventDefault()
    
    // Get form data
    const quantity = parseInt(this.quantityFieldTarget.value, 10)
    const notes = document.getElementById('inventory_notes').value
    const destinationLocationId = document.getElementById('destination_location_id').value
    
    // Validate quantity
    if (!quantity || quantity <= 0) {
      this.showError("Please enter a valid quantity")
      return
    }
    
    // Check if we have enough stock
    const availableStock = parseInt(this.availableStockTarget.textContent, 10)
    if (quantity > availableStock) {
      this.showError(`Cannot transfer more than available quantity (${availableStock})`)
      return
    }
    
    // Validate destination location
    if (!destinationLocationId) {
      this.showError("Please select a destination location")
      return
    }
    
    // Show loading state
    this.setLoadingState(true)
    
    // Send transfer request
    fetch('/api/v1/inventory/transfer', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector("meta[name='csrf-token']").content
      },
      body: JSON.stringify({
        product_id: this.productIdValue,
        source_location_id: this.locationIdValue,
        destination_location_id: destinationLocationId,
        quantity: quantity,
        notes: notes
      })
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        // Show success message
        this.showToast(data.message, "success")
        
        // Refresh inventory data to get updated quantities
        this.fetchInventoryData()
        
        // Clear form
        this.quantityFieldTarget.value = ""
        document.getElementById('inventory_notes').value = ""
      } else {
        // Show error message
        this.showError(data.errors.join(", "))
        this.setLoadingState(false)
      }
    })
    .catch(error => {
      console.error("Error transferring stock:", error)
      this.showError("Error transferring stock. Please try again.")
      this.setLoadingState(false)
    })
  }
  
  // UI Methods
  
  updateInventoryDisplay(data) {
    // Update product information
    if (this.hasProductNameTarget) {
      this.productNameTarget.textContent = data.product.name
    }
    
    // Update location information
    if (this.hasLocationNameTarget) {
      this.locationNameTarget.textContent = data.location.name
    }
    
    // Update inventory information
    this.updateInventoryItem(data.inventory)
    
    // Store inventory ID
    this.inventoryIdValue = data.inventory.id
  }
  
  updateInventoryItem(inventory) {
    // Update stock level
    if (this.hasStockLevelTarget) {
      this.stockLevelTarget.textContent = inventory.quantity || 0
    }
    
    // Update available stock
    if (this.hasAvailableStockTarget) {
      this.availableStockTarget.textContent = inventory.available_quantity || 0
    }
  }
  
  validateQuantity() {
    // Get current quantity value
    const quantity = parseInt(this.quantityFieldTarget.value, 10)
    
    // Check if we're trying to remove or transfer stock
    const actionType = document.getElementById('inventory_action').value
    if (actionType === 'remove' || actionType === 'transfer') {
      // Get available stock
      const availableStock = parseInt(this.availableStockTarget.textContent, 10)
      
      // Validate that we're not removing/transferring more than available
      if (quantity > availableStock) {
        this.showError(`Cannot ${actionType} more than available quantity (${availableStock})`)
        this.quantityFieldTarget.value = availableStock
      } else {
        // Clear error message if valid
        this.clearError()
      }
    } else {
      // Clear error message for add operation
      this.clearError()
    }
  }
  
  setLoadingState(isLoading) {
    // Get action buttons
    const addButton = document.querySelector('button[data-action="inventory-api#addStock"]')
    const removeButton = document.querySelector('button[data-action="inventory-api#removeStock"]')
    const transferButton = document.querySelector('button[data-action="inventory-api#transferStock"]')
    
    if (isLoading) {
      // Disable buttons and show loading indicator
      [addButton, removeButton, transferButton].forEach(button => {
        if (button) {
          button.disabled = true
          button.dataset.originalText = button.innerHTML
          button.innerHTML = '<i class="fas fa-spinner fa-spin mr-2"></i> Processing...'
        }
      })
      
      // Disable form inputs
      this.quantityFieldTarget.disabled = true
      const notesField = document.getElementById('inventory_notes')
      if (notesField) notesField.disabled = true
      const destinationSelect = document.getElementById('destination_location_id')
      if (destinationSelect) destinationSelect.disabled = true
    } else {
      // Re-enable buttons and restore text
      [addButton, removeButton, transferButton].forEach(button => {
        if (button) {
          button.disabled = false
          if (button.dataset.originalText) {
            button.innerHTML = button.dataset.originalText
          }
        }
      })
      
      // Re-enable form inputs
      this.quantityFieldTarget.disabled = false
      const notesField = document.getElementById('inventory_notes')
      if (notesField) notesField.disabled = false
      const destinationSelect = document.getElementById('destination_location_id')
      if (destinationSelect) destinationSelect.disabled = false
    }
  }
  
  showError(message) {
    if (this.hasErrorMessageTarget) {
      this.errorMessageTarget.textContent = message
      this.errorMessageTarget.classList.remove('hidden')
    }
  }
  
  clearError() {
    if (this.hasErrorMessageTarget) {
      this.errorMessageTarget.textContent = ''
      this.errorMessageTarget.classList.add('hidden')
    }
  }
  
  showToast(message, type = "info") {
    const event = new CustomEvent("toast:show", {
      detail: { message, type }
    })
    document.dispatchEvent(event)
  }
  
  // Action handlers based on inventory action type
  
  performAction(event) {
    event.preventDefault()
    
    // Get the current action type
    const actionType = document.getElementById('inventory_action').value
    
    // Call the appropriate method based on the action type
    switch (actionType) {
      case 'add':
        this.addStock(event)
        break
      case 'remove':
        this.removeStock(event)
        break
      case 'transfer':
        this.transferStock(event)
        break
      default:
        console.error(`Unknown action type: ${actionType}`)
    }
  }
  
  // Update UI when action type changes
  
  actionChanged(event) {
    // Get the selected action
    const actionType = event.currentTarget.dataset.action
    
    // Update hidden input value
    document.getElementById('inventory_action').value = actionType
    
    // Update action label
    if (this.hasActionLabelTarget) {
      const actionLabels = {
        add: 'Addition',
        remove: 'Removal',
        transfer: 'Transfer'
      }
      this.actionLabelTarget.textContent = `Reason for ${actionLabels[actionType] || 'Action'}`
    }
    
    // Show/hide destination location field for transfers
    const destinationContainer = document.getElementById('destination_location_container')
    if (destinationContainer) {
      if (actionType === 'transfer') {
        destinationContainer.classList.remove('hidden')
      } else {
        destinationContainer.classList.add('hidden')
      }
    }
    
    // Clear error message
    this.clearError()
    
    // Validate quantity for the new action type
    this.validateQuantity()
  }
}