import { Controller } from "@hotwired/stimulus"

/**
 * Nested Form Controller
 *
 * Handles dynamic addition and removal of nested form fields for order items
 */
export default class extends Controller {
  static targets = ["items", "template"]

  connect() {
    // Initialize form elements
    this.updateOrderTotals()
  }

  /**
   * Add a new nested form fields set for an order item
   */
  add(event) {
    event.preventDefault()
    
    // Create a new form item from the template
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime())
    this.itemsTarget.insertAdjacentHTML("beforeend", content)
    
    // Initialize new fields
    const newFields = this.itemsTarget.lastElementChild
    const selects = newFields.querySelectorAll("select")
    
    // Focus on the first select field
    if (selects.length > 0) {
      selects[0].focus()
    }
  }

  /**
   * Remove a nested form fields set
   */
  remove(event) {
    event.preventDefault()
    
    const item = event.target.closest(".nested-fields")
    
    // If this is a new record, remove it directly
    if (item.dataset.newRecord) {
      item.remove()
    } else {
      // Otherwise, mark it for destruction
      const destroyField = item.querySelector("input[name*='_destroy']")
      destroyField.value = 1
      item.style.display = "none"
    }
    
    // Update order totals
    this.updateOrderTotals()
  }

  /**
   * Calculate and update the subtotal and total amount for the entire order
   */
  updateOrderTotals() {
    let subtotal = 0
    const items = this.element.querySelectorAll('.nested-fields:not([style*="display: none"])')
    
    items.forEach(item => {
      const quantity = parseFloat(item.querySelector('input[name*="quantity"]').value) || 0
      const unitPrice = parseFloat(item.querySelector('input[name*="unit_price"]').value) || 0
      const taxRate = parseFloat(item.querySelector('input[name*="tax_rate"]').value) || 0
      
      const itemSubtotal = quantity * unitPrice
      const itemTax = itemSubtotal * (taxRate / 100)
      const itemTotal = itemSubtotal + itemTax
      
      subtotal += itemSubtotal
    })
    
    // Update the subtotal
    const subtotalDisplay = document.getElementById('subtotal_display')
    const subtotalInput = document.querySelector('input[name*="subtotal"]')
    if (subtotalDisplay && subtotalInput) {
      subtotalDisplay.textContent = subtotal.toFixed(2)
      subtotalInput.value = subtotal.toFixed(2)
    }
    
    // Calculate total amount
    const taxAmount = parseFloat(document.querySelector('input[name*="tax_amount"]').value) || 0
    const shippingAmount = parseFloat(document.querySelector('input[name*="shipping_amount"]').value) || 0
    const discountAmount = parseFloat(document.querySelector('input[name*="discount_amount"]').value) || 0
    
    const totalAmount = subtotal + taxAmount + shippingAmount - discountAmount
    
    // Update the total amount
    const totalDisplay = document.getElementById('total_amount_display')
    const totalInput = document.querySelector('input[name*="total_amount"]')
    if (totalDisplay && totalInput) {
      totalDisplay.textContent = totalAmount.toFixed(2)
      totalInput.value = totalAmount.toFixed(2)
    }
  }
}