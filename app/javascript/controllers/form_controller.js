import { Controller } from "@hotwired/stimulus"

/**
 * Form Controller
 * 
 * Handles form interactions, validations, and submission feedback
 * for the customer form and other forms in the application.
 */
export default class extends Controller {
  connect() {
    // Initialize any form elements that need special handling
    this.initializeFormElements()
  }

  /**
   * Initialize form elements with any special behaviors needed
   */
  initializeFormElements() {
    // Could set up form validation, masks, etc.
    // This is a hook for future enhancements
        
    // Calculate initial totals
    this.updateOrderTotal()
  }

  /**
   * Handle successful form submission
   * @param {Event} event - The turbo:submit-end event
   */
  reset(event) {
    // Only reset the form if the submission was successful
    if (event.detail.success) {
      // Handle any post-submission cleanup if needed
      
      // The actual redirect is handled by the controller's response
      // so we don't need to reset the form manually
    }
  }

  /**
   * Show confirmation dialog before form cancellation if data has been entered
   * @param {Event} event - The click event
   */
  confirmCancel(event) {
    // Check if form has been modified
    const form = this.element
    const formData = new FormData(form)
    let hasValues = false

    // Check if any fields have values
    for (const [name, value] of formData.entries()) {
      if (value && value.length > 0) {
        hasValues = true
        break
      }
    }

    // If form has values, confirm before navigating away
    if (hasValues) {
      if (!confirm("You have unsaved changes. Are you sure you want to leave this page?")) {
        event.preventDefault()
      }
    }
  }
  fetchCustomerDetails(event) {
    const customerId = event.target.value
    
    if (!customerId) return
    
    // Fetch customer details via AJAX
    fetch(`/api/customers/${customerId}`)
      .then(response => response.json())
      .then(data => {
        // Populate shipping and billing addresses from customer data
        if (data.address) {
          const shippingAddressField = this.element.querySelector('textarea[name*="shipping_address"]')
          if (shippingAddressField && !shippingAddressField.value) {
            // Construct address combining available fields
            let address = data.address
            
            if (data.city) address += `\n${data.city}`
            if (data.state) {
              address += data.city ? `, ${data.state}` : `\n${data.state}`
            }
            if (data.postal_code) address += ` ${data.postal_code}`
            if (data.country) address += `\n${data.country}`
            
            shippingAddressField.value = address.trim()
          }
        }
      })
      .catch(error => console.error("Error fetching customer details:", error))
  }

  /**
   * Handle product selection to populate unit price
   * @param {Event} event - The change event
   */
  fetchProductDetails(event) {
    // Find the product ID from the select field
    const productId = event.target.value
    
    if (!productId) return
    
    // Find the parent item container
    const itemContainer = event.target.closest('.nested-fields')
    if (!itemContainer) return
    
    // Find the unit price field in the same container
    const unitPriceField = itemContainer.querySelector('input[name*="unit_price"]')
    if (!unitPriceField) return
    
    // Fetch product details via AJAX
    fetch(`/api/products/${productId}`)
      .then(response => response.json())
      .then(data => {
        // Populate the unit price field with the product's selling price
        if (data.selling_price && !unitPriceField.value) {
          unitPriceField.value = data.selling_price
          
          // Update item total and order total
          this.updateItemTotal(event)
        }
      })
      .catch(error => console.error("Error fetching product details:", error))
  }

  /**
   * Copy shipping address to billing address when checkbox is checked
   * @param {Event} event - The change event
   */
  copyShippingAddress(event) {
    const isChecked = event.target.checked
    const shippingAddressField = this.element.querySelector('textarea[name*="shipping_address"]')
    const billingAddressField = this.element.querySelector('textarea[name*="billing_address"]')
    
    if (isChecked && shippingAddressField && billingAddressField) {
      billingAddressField.value = shippingAddressField.value
    } else if (!isChecked && billingAddressField) {
      billingAddressField.value = ''
    }
  }

  /**
   * Calculate and update the total for a specific order item
   * @param {Event} event - The change event
   */
  updateItemTotal(event) {
    // Find the parent item container
    const itemContainer = event.target.closest('.nested-fields')
    if (!itemContainer) return
    
    // Get values
    const quantityField = itemContainer.querySelector('input[name*="quantity"]')
    const unitPriceField = itemContainer.querySelector('input[name*="unit_price"]')
    const taxRateField = itemContainer.querySelector('input[name*="tax_rate"]')
    
    if (!quantityField || !unitPriceField) return
    
    const quantity = parseFloat(quantityField.value) || 0
    const unitPrice = parseFloat(unitPriceField.value) || 0
    const taxRate = parseFloat(taxRateField?.value) || 0
    
    // Call the nested form controller to update all totals
    const nestedFormController = this.application.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller="nested-form"]'),
      'nested-form'
    )
    
    if (nestedFormController) {
      nestedFormController.updateOrderTotals()
    }
  }

  /**
   * Update the order total based on changes to tax, shipping, or discount
   * @param {Event} event - The change event
   */
  updateOrderTotal(event) {
    // Call the nested form controller to update all totals
    const nestedFormController = this.application.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller="nested-form"]'),
      'nested-form'
    )
    
    if (nestedFormController) {
      nestedFormController.updateOrderTotals()
    }
  }

  /**
   * Handle successful form submission
   * @param {Event} event - The turbo:submit-end event
   */
  reset(event) {
    // Only reset the form if the submission was successful
    if (event.detail.success) {
      // Handle any post-submission cleanup if needed
    }
  }

  /**
   * Submit the form
   * @param {Event} event - The submit event
   */
  submit(event) {
    // Ensure all calculations are up to date before submitting
    this.updateOrderTotal()
  }
}