// Modal Helpers
// A set of utility functions for working with modals in the application

/**
 * Open a modal with data
 * @param {string} modalId - The ID of the modal to open
 * @param {Object} data - The data to pass to the modal
 */
export function openModal(modalId, data = {}) {
  const event = new CustomEvent("modal:open", { 
    detail: { id: modalId, data } 
  })
  document.dispatchEvent(event)
}

/**
 * Close a modal
 * @param {string} modalId - The ID of the modal to close
 */
export function closeModal(modalId) {
  const modal = document.getElementById(modalId)
  if (!modal) return
  
  const controller = window.Stimulus.getControllerForElementAndIdentifier(modal, "modal")
  if (controller) controller.close()
}

/**
 * Show a toast message
 * @param {string} message - The message to show
 * @param {string} type - The type of message (info, success, error, warning)
 */
export function showToast(message, type = "info") {
  const event = new CustomEvent("toast:show", {
    detail: { message, type }
  })
  document.dispatchEvent(event)
}

/**
 * Create a product modal helper
 * @param {Object} product - Optional product data for editing (leave empty for create)
 */
export function showProductModal(product = null) {
  const isEdit = product !== null
  const modalId = "product-modal"
  
  if (isEdit) {
    openModal(modalId, {
      title: "Edit Product",
      action: `/products/${product.id}`,
      method: "patch",
      resourceId: product.id,
      submitText: "Update Product"
    })
    
    // Additional logic to populate the form would go here
    // This is usually handled in the controller that opens the modal
  } else {
    openModal(modalId, {
      title: "Create New Product",
      action: "/products",
      method: "post",
      submitText: "Create Product"
    })
  }
}

/**
 * Show inventory action modal
 * @param {Object} product - The product to manage inventory for
 * @param {Object} location - The location to manage inventory at
 * @param {number} quantity - The current quantity
 * @param {number} availableQuantity - The available quantity
 * @param {Array} locations - Available locations for transfers
 */
export function showInventoryActionModal(product, location, quantity, availableQuantity, locations) {
  const modalId = "inventory-action-modal"
  
  openModal(modalId, {
    title: `Manage Inventory: ${product.name}`,
    action: "/inventory/update",
    method: "patch",
    submitText: "Apply Changes"
  })
  
  // Call the populate function defined in the modal
  if (typeof window.populateInventoryModal === "function") {
    window.populateInventoryModal(
      product.id,
      product.name,
      location.id,
      location.name,
      quantity,
      availableQuantity,
      locations
    )
  }
}

/**
 * Show location selector modal
 * @param {Function} onSelect - Callback function when a location is selected
 */
export function showLocationSelectorModal(onSelect) {
  const modalId = "location-selector-modal"
  
  // Add one-time event listener for location selection
  const handleLocationSelected = (event) => {
    if (typeof onSelect === "function") {
      onSelect(event.detail.location)
    }
    document.removeEventListener("location:selected", handleLocationSelected)
  }
  
  document.addEventListener("location:selected", handleLocationSelected)
  
  // Open the modal
  openModal(modalId)
}

/**
 * Format currency in Ghana Cedis
 * @param {number} amount - The amount to format
 * @returns {string} Formatted currency string
 */
export function formatCurrency(amount) {
  if (amount === null || amount === undefined) return '₵0.00'
  return new Intl.NumberFormat('en-GH', { style: 'currency', currency: 'GHS', minimumFractionDigits: 2 }).format(amount)
}

/**
 * Format date
 * @param {string} dateString - The date string to format
 * @returns {string} Formatted date string
 */
export function formatDate(dateString) {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleDateString('en-GH', { 
    year: 'numeric', 
    month: 'short', 
    day: 'numeric'
  })
}

/**
 * Format date and time
 * @param {string} dateString - The date string to format
 * @returns {string} Formatted date and time string
 */
export function formatDateTime(dateString) {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleDateString('en-GH', { 
    year: 'numeric', 
    month: 'short', 
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

/**
 * Show inventory transfer modal for moving stock between locations
 */
export function showInventoryModal() {
  const modalId = "inventory-transfer-modal"
  
  openModal(modalId, {
    title: "Transfer Inventory",
    action: "/inventory/transfer",
    method: "post",
    submitText: "Transfer Stock"
  })
}

/**
 * Show modal for creating a new location
 */
export function showLocationModal() {
  const modalId = "location-modal"
  
  openModal(modalId, {
    title: "Create New Location",
    action: "/locations",
    method: "post",
    submitText: "Create Location"
  })
}

/**
 * Show customer details in a modal
 * @param {number} customerId - The ID of the customer to show
 */
export function showCustomerDetailsModal(customerId) {
  const modalId = "customer-details-modal"
  const modalContent = document.getElementById('customer-modal-content')
  
  if (!modalContent) return;
  
  // Show loading spinner
  modalContent.innerHTML = `
    <div class="flex justify-center items-center py-12">
      <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600"></div>
    </div>
  `;
  
  // Open the modal
  openModal(modalId)
  
  // Fetch customer details
  fetch(`/customers/${customerId}?format=html&modal=true`)
    .then(response => {
      if (!response.ok) {
        throw new Error('Network response was not ok');
      }
      return response.text();
    })
    .then(html => {
      modalContent.innerHTML = html;
    })
    .catch(error => {
      modalContent.innerHTML = `
        <div class="bg-red-50 dark:bg-red-900/20 border-l-4 border-red-500 p-4">
          <div class="flex">
            <div class="flex-shrink-0">
              <i class="fas fa-exclamation-circle text-red-500"></i>
            </div>
            <div class="ml-3">
              <p class="text-sm text-red-700 dark:text-red-200">
                Error loading customer details: ${error.message}
              </p>
            </div>
          </div>
        </div>
      `;
    });
}

// Initialize global ModalHelpers object for use in views
window.ModalHelpers = {
  showProductModal,
  showInventoryModal,
  showLocationModal,
  showInventoryActionModal,
  showLocationSelectorModal,
  showCustomerDetailsModal,
  openModal,
  closeModal,
  showToast,
  formatCurrency,
  formatDate,
  formatDateTime
};

// Ensure ModalHelpers is available immediately and after DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
  // Re-assign to ensure it's available even if overwritten elsewhere
  window.ModalHelpers = window.ModalHelpers || {};
  Object.assign(window.ModalHelpers, {
    showProductModal,
    showInventoryModal,
    showLocationModal,
    showInventoryActionModal,
    showLocationSelectorModal,
    showCustomerDetailsModal,
    openModal,
    closeModal,
    showToast,
    formatCurrency,
    formatDate,
    formatDateTime
  });
});