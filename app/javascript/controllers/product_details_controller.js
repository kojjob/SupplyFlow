import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "loading", "content", "error",
    "productName", "skuBadge", "categoryBadge", "stockBadge",
    "sellingPrice", "costPrice", "margin",
    "description", "brand", "uom", "dimensions", "weight", "perishable",
    "stockLevel", "stockBar", "availableStock", "reservedStock", 
    "reorderPoint", "minimumStock",
    "inventoryTable", "transactionsTable", "viewAllTransactionsLink"
  ]
  
  static values = {
    productId: Number
  }
  
  connect() {
    if (this.productIdValue > 0) {
      this.fetchProductData()
    }
  }
  
  productIdValueChanged() {
    if (this.productIdValue > 0) {
      this.fetchProductData()
    }
  }
  
  // Data fetching
  fetchProductData() {
    // Show loading state
    this.showLoading()
    
    // Fetch data from API
    fetch(`/api/v1/products/${this.productIdValue}`)
      .then(response => {
        if (!response.ok) throw new Error('Network response was not ok')
        return response.json()
      })
      .then(data => {
        this.updateProductDetails(data)
        this.showContent()
      })
      .catch(error => {
        console.error("Error fetching product data:", error)
        this.showError()
      })
  }
  
  fetchInventoryData() {
    // Fetch inventory data from API
    fetch(`/api/v1/products/${this.productIdValue}/inventory`)
      .then(response => {
        if (!response.ok) throw new Error('Network response was not ok')
        return response.json()
      })
      .then(data => {
        this.updateInventoryDetails(data)
      })
      .catch(error => {
        console.error("Error fetching inventory data:", error)
        // We won't show an error, just leave the current data as is
      })
  }
  
  // Data rendering
  updateProductDetails(data) {
    // Basic product details
    this.productNameTarget.textContent = data.name
    this.skuBadgeTarget.textContent = `SKU: ${data.sku}`
    this.categoryBadgeTarget.textContent = data.category ? `Category: ${data.category}` : 'Uncategorized'
    
    // Stock status
    this.updateStockStatus(data)
    
    // Pricing
    this.sellingPriceTarget.textContent = this.formatCurrency(data.selling_price)
    this.costPriceTarget.textContent = this.formatCurrency(data.cost_price)
    this.marginTarget.textContent = data.profit_margin ? `${data.profit_margin}%` : 'N/A'
    
    // Details
    this.descriptionTarget.textContent = data.description || 'No description provided.'
    this.brandTarget.textContent = data.brand || 'N/A'
    this.uomTarget.textContent = data.unit_of_measure || 'Unit'
    this.dimensionsTarget.textContent = data.format_dimensions || 'N/A'
    this.weightTarget.textContent = data.weight ? `${data.weight} ${data.weight_unit || 'kg'}` : 'N/A'
    this.perishableTarget.textContent = data.perishable ? 'Yes' : 'No'
    
    // Inventory summary
    this.stockLevelTarget.textContent = `${data.total_quantity} / ${Math.max(data.total_quantity, data.reorder_point * 2)}`
    
    // Calculate stock bar percentage
    const maxReference = Math.max(data.total_quantity, data.reorder_point * 2)
    const stockPercentage = Math.min(100, Math.round((data.total_quantity / maxReference) * 100))
    this.stockBarTarget.style.width = `${stockPercentage}%`
    
    // Set stock bar color based on stock level
    if (data.out_of_stock) {
      this.stockBarTarget.classList.add('bg-red-600')
      this.stockBarTarget.classList.remove('bg-amber-500', 'bg-green-500')
    } else if (data.low_stock) {
      this.stockBarTarget.classList.add('bg-amber-500')
      this.stockBarTarget.classList.remove('bg-red-600', 'bg-green-500')
    } else {
      this.stockBarTarget.classList.add('bg-green-500')
      this.stockBarTarget.classList.remove('bg-red-600', 'bg-amber-500')
    }
    
    // Available and reserved stock
    this.availableStockTarget.textContent = data.available_quantity
    this.reservedStockTarget.textContent = data.reserved_quantity
    
    // Reorder points
    this.reorderPointTarget.textContent = data.reorder_point
    this.minimumStockTarget.textContent = data.minimum_stock_level
    
    // Set links
    this.viewAllTransactionsLinkTarget.href = `/inventory/transactions?product_id=${data.id}`
    
    // Load inventory items
    if (data.inventory_items) {
      this.renderInventoryItems(data.inventory_items)
    }
  }
  
  updateInventoryDetails(data) {
    // Update inventory items table
    this.renderInventoryItems(data.inventory_items)
    
    // Update transaction history
    this.renderTransactions(data.transactions)
    
    // Update stock summary
    this.stockLevelTarget.textContent = `${data.totals.total_quantity} / ${Math.max(data.totals.total_quantity, data.product.reorder_point * 2)}`
    this.availableStockTarget.textContent = data.totals.available_quantity
    this.reservedStockTarget.textContent = data.totals.reserved_quantity
    
    // Update stock bar
    const maxReference = Math.max(data.totals.total_quantity, data.product.reorder_point * 2)
    const stockPercentage = Math.min(100, Math.round((data.totals.total_quantity / maxReference) * 100))
    this.stockBarTarget.style.width = `${stockPercentage}%`
    
    // Update stock status badge
    this.updateStockStatusFromTotals(data.totals)
  }
  
  // UI helpers
  showLoading() {
    this.loadingTarget.classList.remove('hidden')
    this.contentTarget.classList.add('hidden')
    this.errorTarget.classList.add('hidden')
  }
  
  showContent() {
    this.loadingTarget.classList.add('hidden')
    this.contentTarget.classList.remove('hidden')
    this.errorTarget.classList.add('hidden')
  }
  
  showError() {
    this.loadingTarget.classList.add('hidden')
    this.contentTarget.classList.add('hidden')
    this.errorTarget.classList.remove('hidden')
  }
  
  updateStockStatus(data) {
    // Update stock status badge based on stock level
    if (data.out_of_stock) {
      this.stockBadgeTarget.textContent = 'Out of Stock'
      this.stockBadgeTarget.classList.add('bg-red-100', 'text-red-800', 'dark:bg-red-900/30', 'dark:text-red-300')
      this.stockBadgeTarget.classList.remove('bg-amber-100', 'text-amber-800', 'dark:bg-amber-900/30', 'dark:text-amber-300', 'bg-green-100', 'text-green-800', 'dark:bg-green-900/30', 'dark:text-green-300')
    } else if (data.low_stock) {
      this.stockBadgeTarget.textContent = 'Low Stock'
      this.stockBadgeTarget.classList.add('bg-amber-100', 'text-amber-800', 'dark:bg-amber-900/30', 'dark:text-amber-300')
      this.stockBadgeTarget.classList.remove('bg-red-100', 'text-red-800', 'dark:bg-red-900/30', 'dark:text-red-300', 'bg-green-100', 'text-green-800', 'dark:bg-green-900/30', 'dark:text-green-300')
    } else {
      this.stockBadgeTarget.textContent = 'In Stock'
      this.stockBadgeTarget.classList.add('bg-green-100', 'text-green-800', 'dark:bg-green-900/30', 'dark:text-green-300')
      this.stockBadgeTarget.classList.remove('bg-red-100', 'text-red-800', 'dark:bg-red-900/30', 'dark:text-red-300', 'bg-amber-100', 'text-amber-800', 'dark:bg-amber-900/30', 'dark:text-amber-300')
    }
  }
  
  updateStockStatusFromTotals(totals) {
    // Update stock status badge based on totals
    if (totals.out_of_stock) {
      this.stockBadgeTarget.textContent = 'Out of Stock'
      this.stockBadgeTarget.classList.add('bg-red-100', 'text-red-800', 'dark:bg-red-900/30', 'dark:text-red-300')
      this.stockBadgeTarget.classList.remove('bg-amber-100', 'text-amber-800', 'dark:bg-amber-900/30', 'dark:text-amber-300', 'bg-green-100', 'text-green-800', 'dark:bg-green-900/30', 'dark:text-green-300')
    } else if (totals.low_stock) {
      this.stockBadgeTarget.textContent = 'Low Stock'
      this.stockBadgeTarget.classList.add('bg-amber-100', 'text-amber-800', 'dark:bg-amber-900/30', 'dark:text-amber-300')
      this.stockBadgeTarget.classList.remove('bg-red-100', 'text-red-800', 'dark:bg-red-900/30', 'dark:text-red-300', 'bg-green-100', 'text-green-800', 'dark:bg-green-900/30', 'dark:text-green-300')
    } else {
      this.stockBadgeTarget.textContent = 'In Stock'
      this.stockBadgeTarget.classList.add('bg-green-100', 'text-green-800', 'dark:bg-green-900/30', 'dark:text-green-300')
      this.stockBadgeTarget.classList.remove('bg-red-100', 'text-red-800', 'dark:bg-red-900/30', 'dark:text-red-300', 'bg-amber-100', 'text-amber-800', 'dark:bg-amber-900/30', 'dark:text-amber-300')
    }
  }
  
  renderInventoryItems(items) {
    // Clear existing data
    this.inventoryTableTarget.innerHTML = ''
    
    // Check if we have items
    if (!items || items.length === 0) {
      this.inventoryTableTarget.innerHTML = `
        <tr>
          <td colspan="6" class="px-4 py-4 text-center text-sm text-gray-500 dark:text-gray-400">
            No inventory items found for this product.
          </td>
        </tr>
      `
      return
    }
    
    // Render each item
    items.forEach(item => {
      // Create row element
      const row = document.createElement('tr')
      row.classList.add('hover:bg-gray-50', 'dark:hover:bg-gray-750')
      
      // Status class
      let statusClass = 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300'
      if (item.status === 'reserved') {
        statusClass = 'bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-300'
      } else if (item.status === 'damaged' || item.status === 'expired') {
        statusClass = 'bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-300'
      } else if (item.status === 'quarantined') {
        statusClass = 'bg-amber-100 text-amber-800 dark:bg-amber-900/30 dark:text-amber-300'
      }
      
      // Populate row
      row.innerHTML = `
        <td class="px-4 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white">
          ${item.location_name}
        </td>
        <td class="px-4 py-4 whitespace-nowrap text-sm text-gray-700 dark:text-gray-300">
          ${item.quantity}
        </td>
        <td class="px-4 py-4 whitespace-nowrap text-sm text-gray-700 dark:text-gray-300">
          ${item.available_quantity}
        </td>
        <td class="px-4 py-4 whitespace-nowrap text-sm text-gray-700 dark:text-gray-300">
          ${item.reserved_quantity}
        </td>
        <td class="px-4 py-4 whitespace-nowrap text-sm">
          <span class="px-2 py-1 inline-flex text-xs leading-5 font-medium rounded-full ${statusClass}">
            ${item.status.charAt(0).toUpperCase() + item.status.slice(1)}
          </span>
        </td>
        <td class="px-4 py-4 whitespace-nowrap text-sm text-right space-x-2">
          <button
            type="button"
            data-action="product-details#addStock"
            data-location-id="${item.location_id}"
            class="text-green-600 hover:text-green-800 dark:text-green-400 dark:hover:text-green-300"
            title="Add stock"
          >
            <i class="fas fa-plus-circle"></i>
          </button>
          <button
            type="button"
            data-action="product-details#removeStock"
            data-location-id="${item.location_id}"
            class="text-red-600 hover:text-red-800 dark:text-red-400 dark:hover:text-red-300"
            title="Remove stock"
          >
            <i class="fas fa-minus-circle"></i>
          </button>
          <button
            type="button"
            data-action="product-details#transferStock"
            data-location-id="${item.location_id}"
            class="text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300"
            title="Transfer stock"
          >
            <i class="fas fa-exchange-alt"></i>
          </button>
        </td>
      `
      
      // Add to table
      this.inventoryTableTarget.appendChild(row)
    })
  }
  
  renderTransactions(transactions) {
    // Clear existing data
    this.transactionsTableTarget.innerHTML = ''
    
    // Check if we have transactions
    if (!transactions || transactions.length === 0) {
      this.transactionsTableTarget.innerHTML = `
        <tr>
          <td colspan="6" class="px-4 py-4 text-center text-sm text-gray-500 dark:text-gray-400">
            No transaction history found for this product.
          </td>
        </tr>
      `
      return
    }
    
    // Render each transaction
    transactions.forEach(transaction => {
      // Create row element
      const row = document.createElement('tr')
      row.classList.add('hover:bg-gray-50', 'dark:hover:bg-gray-750')
      
      // Get transaction type display
      let typeDisplay = transaction.transaction_type.replace(/_/g, ' ')
      typeDisplay = typeDisplay.charAt(0).toUpperCase() + typeDisplay.slice(1)
      
      // Get type badge class
      let typeClass = 'bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-300'
      if (transaction.transaction_type === 'stock_addition') {
        typeClass = 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300'
      } else if (transaction.transaction_type === 'stock_removal') {
        typeClass = 'bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-300'
      } else if (transaction.transaction_type === 'adjustment') {
        typeClass = 'bg-amber-100 text-amber-800 dark:bg-amber-900/30 dark:text-amber-300'
      }
      
      // Format date
      const date = new Date(transaction.created_at)
      const formattedDate = date.toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      })
      
      // Populate row
      row.innerHTML = `
        <td class="px-4 py-4 whitespace-nowrap text-sm text-gray-700 dark:text-gray-300">
          ${formattedDate}
        </td>
        <td class="px-4 py-4 whitespace-nowrap text-sm">
          <span class="px-2 py-1 inline-flex text-xs leading-5 font-medium rounded-full ${typeClass}">
            ${typeDisplay}
          </span>
        </td>
        <td class="px-4 py-4 whitespace-nowrap text-sm text-gray-700 dark:text-gray-300">
          ${transaction.quantity}
        </td>
        <td class="px-4 py-4 whitespace-nowrap text-sm text-gray-700 dark:text-gray-300">
          ${transaction.source_location || 'N/A'}
        </td>
        <td class="px-4 py-4 whitespace-nowrap text-sm text-gray-700 dark:text-gray-300">
          ${transaction.destination_location || 'N/A'}
        </td>
        <td class="px-4 py-4 whitespace-nowrap text-sm text-gray-700 dark:text-gray-300">
          ${transaction.user}
        </td>
      `
      
      // Add to table
      this.transactionsTableTarget.appendChild(row)
    })
  }
  
  // Action handlers
  
  retryLoad(event) {
    event.preventDefault()
    this.fetchProductData()
  }
  
  editProduct(event) {
    event.preventDefault()
    
    // Open the product edit modal
    if (window.ModalHelpers) {
      window.ModalHelpers.showProductModal({ id: this.productIdValue })
    } else {
      const productModal = document.getElementById('product-modal')
      if (productModal) {
        const controller = window.Stimulus.getControllerForElementAndIdentifier(productModal, 'modal')
        if (controller) {
          controller.openWithData({
            title: "Edit Product",
            action: `/products/${this.productIdValue}`,
            method: "patch",
            resourceId: this.productIdValue,
            submitText: "Update Product"
          })
          
          // Close this modal
          const detailsModal = document.getElementById('product-details-modal')
          if (detailsModal) {
            const detailsController = window.Stimulus.getControllerForElementAndIdentifier(detailsModal, 'modal')
            if (detailsController) {
              detailsController.close()
            }
          }
        }
      }
    }
  }
  
  manageInventory(event) {
    event.preventDefault()
    
    // Show location selector to pick location for inventory management
    if (window.ModalHelpers) {
      window.ModalHelpers.showLocationSelectorModal((location) => {
        this.openInventoryModal(location.id)
      })
    } else {
      // Fallback - open location selector directly
      const locationModal = document.getElementById('location-selector-modal')
      if (locationModal) {
        const controller = window.Stimulus.getControllerForElementAndIdentifier(locationModal, 'modal')
        if (controller) {
          controller.open()
          
          // Add one-time event listener for location selection
          const handleLocationSelected = (event) => {
            const location = event.detail.location
            this.openInventoryModal(location.id)
            document.removeEventListener("location:selected", handleLocationSelected)
          }
          
          document.addEventListener("location:selected", handleLocationSelected)
        }
      }
    }
  }
  
  addStock(event) {
    event.preventDefault()
    const locationId = event.currentTarget.dataset.locationId
    this.openInventoryModalWithAction(locationId, 'add')
  }
  
  removeStock(event) {
    event.preventDefault()
    const locationId = event.currentTarget.dataset.locationId
    this.openInventoryModalWithAction(locationId, 'remove')
  }
  
  transferStock(event) {
    event.preventDefault()
    const locationId = event.currentTarget.dataset.locationId
    this.openInventoryModalWithAction(locationId, 'transfer')
  }
  
  addToLocation(event) {
    event.preventDefault()
    
    // Show location selector to pick a new location
    if (window.ModalHelpers) {
      window.ModalHelpers.showLocationSelectorModal((location) => {
        this.openInventoryModalWithAction(location.id, 'add')
      })
    } else {
      // Fallback - open location selector directly
      const locationModal = document.getElementById('location-selector-modal')
      if (locationModal) {
        const controller = window.Stimulus.getControllerForElementAndIdentifier(locationModal, 'modal')
        if (controller) {
          controller.open()
          
          // Add one-time event listener for location selection
          const handleLocationSelected = (event) => {
            const location = event.detail.location
            this.openInventoryModalWithAction(location.id, 'add')
            document.removeEventListener("location:selected", handleLocationSelected)
          }
          
          document.addEventListener("location:selected", handleLocationSelected)
        }
      }
    }
  }
  
  // Helper methods
  
  openInventoryModal(locationId) {
    // Fetch inventory data for this product and location
    fetch(`/api/v1/inventory?product_id=${this.productIdValue}&location_id=${locationId}`)
      .then(response => response.json())
      .then(data => {
        // Close this modal first
        const detailsModal = document.getElementById('product-details-modal')
        if (detailsModal) {
          const detailsController = window.Stimulus.getControllerForElementAndIdentifier(detailsModal, 'modal')
          if (detailsController) {
            detailsController.close()
          }
        }
        
        // Open inventory action modal
        const inventoryModal = document.getElementById('inventory-action-modal')
        if (inventoryModal) {
          const controller = window.Stimulus.getControllerForElementAndIdentifier(inventoryModal, 'modal')
          if (controller) {
            controller.openWithData({
              title: `Manage Inventory: ${data.product.name}`,
              action: "/inventory/update",
              method: "patch",
              submitText: "Apply Changes"
            })
            
            // Populate the inventory modal with product and location data
            window.populateInventoryModal(
              data.product.id,
              data.product.name,
              data.location.id,
              data.location.name,
              data.inventory.quantity || 0,
              data.inventory.available_quantity || 0,
              data.available_locations
            )
          }
        }
      })
      .catch(error => {
        console.error("Error fetching inventory data:", error)
        // Show error toast
        this.showToast("Error loading inventory data. Please try again.", "error")
      })
  }
  
  openInventoryModalWithAction(locationId, action) {
    // Fetch inventory data for this product and location
    fetch(`/api/v1/inventory?product_id=${this.productIdValue}&location_id=${locationId}`)
      .then(response => response.json())
      .then(data => {
        // Close this modal first
        const detailsModal = document.getElementById('product-details-modal')
        if (detailsModal) {
          const detailsController = window.Stimulus.getControllerForElementAndIdentifier(detailsModal, 'modal')
          if (detailsController) {
            detailsController.close()
          }
        }
        
        // Open inventory action modal
        const inventoryModal = document.getElementById('inventory-action-modal')
        if (inventoryModal) {
          const controller = window.Stimulus.getControllerForElementAndIdentifier(inventoryModal, 'modal')
          if (controller) {
            // Set title based on action
            let title = `Manage Inventory: ${data.product.name}`
            if (action === 'add') {
              title = `Add Stock: ${data.product.name}`
            } else if (action === 'remove') {
              title = `Remove Stock: ${data.product.name}`
            } else if (action === 'transfer') {
              title = `Transfer Stock: ${data.product.name}`
            }
            
            controller.openWithData({
              title: title,
              action: "/inventory/update",
              method: "patch",
              submitText: "Apply Changes"
            })
            
            // Populate the inventory modal with product and location data
            window.populateInventoryModal(
              data.product.id,
              data.product.name,
              data.location.id,
              data.location.name,
              data.inventory.quantity || 0,
              data.inventory.available_quantity || 0,
              data.available_locations
            )
            
            // Set the action
            const actionInput = document.getElementById('inventory_action')
            if (actionInput) {
              actionInput.value = action
            }
            
            // Update UI to match action
            const actionOptions = document.querySelectorAll('.action-option')
            actionOptions.forEach(option => {
              option.classList.remove('active')
              if (option.dataset.action === action) {
                option.classList.add('active')
              }
            })
            
            // Show/hide destination container
            const destinationContainer = document.getElementById('destination_location_container')
            if (destinationContainer) {
              if (action === 'transfer') {
                destinationContainer.classList.remove('hidden')
              } else {
                destinationContainer.classList.add('hidden')
              }
            }
            
            // Update notes label
            const notesLabel = document.getElementById('notes_label')
            if (notesLabel) {
              const labels = {
                add: 'Reason for Addition',
                remove: 'Reason for Removal',
                transfer: 'Reason for Transfer'
              }
              notesLabel.textContent = labels[action] || 'Notes'
            }
            
            // Show the appropriate action button
            const addButton = document.querySelector('.add-action-btn')
            const removeButton = document.querySelector('.remove-action-btn')
            const transferButton = document.querySelector('.transfer-action-btn')
            
            if (addButton) addButton.classList.add('hidden')
            if (removeButton) removeButton.classList.add('hidden')
            if (transferButton) transferButton.classList.add('hidden')
            
            if (action === 'add' && addButton) {
              addButton.classList.remove('hidden')
            } else if (action === 'remove' && removeButton) {
              removeButton.classList.remove('hidden')
            } else if (action === 'transfer' && transferButton) {
              transferButton.classList.remove('hidden')
            }
          }
        }
      })
      .catch(error => {
        console.error("Error fetching inventory data:", error)
        // Show error toast
        this.showToast("Error loading inventory data. Please try again.", "error")
      })
  }
  
  formatCurrency(amount) {
    if (amount === null || amount === undefined) return '₵0.00'
    return new Intl.NumberFormat('en-GH', { style: 'currency', currency: 'GHS', minimumFractionDigits: 2 }).format(amount)
  }
  
  showToast(message, type = "info") {
    const event = new CustomEvent("toast:show", {
      detail: { message, type }
    })
    document.dispatchEvent(event)
  }
}