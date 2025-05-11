import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["productList", "searchInput", "categoryFilter", "statusFilter", "pagination"]
  
  connect() {
    console.log("Products controller connected")
    this.loadProducts()
  }
  
  // Load products with current filters
  loadProducts(page = 1) {
    const searchTerm = this.hasSearchInputTarget ? this.searchInputTarget.value : ""
    const categoryFilter = this.hasCategoryFilterTarget ? this.categoryFilterTarget.value : ""
    const statusFilter = this.hasStatusFilterTarget ? this.statusFilterTarget.value : ""
    
    // Show loading state
    if (this.hasProductListTarget) {
      this.productListTarget.innerHTML = this.loadingTemplate()
    }
    
    // Fetch products
    fetch(`/products.json?page=${page}&search=${encodeURIComponent(searchTerm)}&category=${encodeURIComponent(categoryFilter)}&status=${encodeURIComponent(statusFilter)}`)
      .then(response => response.json())
      .then(data => {
        this.renderProducts(data.products)
        if (this.hasPaginationTarget) {
          this.renderPagination(data.pagination)
        }
      })
      .catch(error => {
        console.error("Error loading products:", error)
        if (this.hasProductListTarget) {
          this.productListTarget.innerHTML = `
            <div class="text-center py-12">
              <div class="w-20 h-20 mx-auto bg-red-100 dark:bg-red-900/30 rounded-full flex items-center justify-center text-red-500 dark:text-red-400 mb-4">
                <i class="fas fa-exclamation-triangle text-2xl"></i>
              </div>
              <h3 class="text-base font-medium text-gray-900 dark:text-white">Error loading products</h3>
              <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">Please try again later.</p>
              <button class="mt-4 inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-[#0055A4] hover:bg-[#004890]" data-action="products#loadProducts">
                <i class="fas fa-sync-alt mr-2"></i> Try Again
              </button>
            </div>
          `
        }
      })
  }
  
  // Render products
  renderProducts(products) {
    if (!this.hasProductListTarget) return
    
    if (!products || products.length === 0) {
      this.productListTarget.innerHTML = this.emptyStateTemplate()
      return
    }
    
    this.productListTarget.innerHTML = ""
    
    products.forEach(product => {
      const productCard = document.createElement("div")
      productCard.className = "bg-white dark:bg-gray-800 shadow rounded-lg overflow-hidden flex flex-col h-full"
      productCard.dataset.productId = product.id
      
      const stockStatus = this.getStockStatusInfo(product)
      
      productCard.innerHTML = `
        <div class="p-4 flex-1">
          <div class="flex items-center justify-between mb-2">
            <span class="px-2 py-1 text-xs font-medium rounded-full ${stockStatus.bgClass} ${stockStatus.textClass}">
              ${stockStatus.label}
            </span>
            <div class="text-gray-500 dark:text-gray-400">
              <button type="button" class="hover:text-gray-700 dark:hover:text-gray-300 focus:outline-none" data-action="products#showProductMenu" data-product-id="${product.id}">
                <i class="fas fa-ellipsis-v"></i>
              </button>
            </div>
          </div>
          
          <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-1 line-clamp-2">${product.name}</h3>
          <p class="text-sm text-gray-500 dark:text-gray-400 mb-2">SKU: ${product.sku}</p>
          
          <div class="grid grid-cols-2 gap-2 mt-3">
            <div>
              <p class="text-xs text-gray-500 dark:text-gray-400">Price</p>
              <p class="text-sm font-medium">${this.formatCurrency(product.selling_price)}</p>
            </div>
            <div>
              <p class="text-xs text-gray-500 dark:text-gray-400">Stock</p>
              <p class="text-sm font-medium">${product.total_quantity} ${product.unit_of_measure || 'units'}</p>
            </div>
          </div>
        </div>
        
        <div class="border-t border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-750 p-3 flex items-center justify-between">
          <button type="button" class="inline-flex items-center text-sm text-gray-700 dark:text-gray-300 hover:text-[#0055A4] dark:hover:text-[#0055A4] transition-colors" data-action="products#viewProduct" data-product-id="${product.id}">
            <i class="fas fa-eye mr-1"></i> View
          </button>
          <button type="button" class="inline-flex items-center text-sm text-gray-700 dark:text-gray-300 hover:text-[#0055A4] dark:hover:text-[#0055A4] transition-colors" data-action="products#editProduct" data-product-id="${product.id}">
            <i class="fas fa-edit mr-1"></i> Edit
          </button>
          <button type="button" class="inline-flex items-center text-sm text-gray-700 dark:text-gray-300 hover:text-[#0055A4] dark:hover:text-[#0055A4] transition-colors" data-action="products#manageInventory" data-product-id="${product.id}">
            <i class="fas fa-boxes mr-1"></i> Inventory
          </button>
        </div>
      `
      
      this.productListTarget.appendChild(productCard)
    })
  }
  
  // Handle search input
  search() {
    this.loadProducts(1) // Reset to first page on search
  }
  
  // Handle filter changes
  filter() {
    this.loadProducts(1) // Reset to first page on filter changes
  }
  
  // Handle pagination
  changePage(event) {
    event.preventDefault()
    const page = event.currentTarget.dataset.page
    this.loadProducts(page)
  }
  
  // Open create product modal
  createProduct() {
    const modal = document.getElementById("product-modal")
    if (!modal) return
    
    // Reset form if needed
    const form = modal.querySelector("form")
    if (form) form.reset()
    
    // Set modal title and button text
    const modalController = this.application.getControllerForElementAndIdentifier(modal, "modal")
    if (modalController) {
      modalController.openWithData({
        title: "Create New Product",
        action: "/products",
        method: "post",
        submitText: "Create Product"
      })
    }
  }
  
  // Open edit product modal
  editProduct(event) {
    const productId = event.currentTarget.dataset.productId
    if (!productId) return
    
    // Fetch product data
    fetch(`/products/${productId}.json`)
      .then(response => response.json())
      .then(product => {
        const modal = document.getElementById("product-modal")
        if (!modal) return
        
        // Set modal title and button text
        const modalController = this.application.getControllerForElementAndIdentifier(modal, "modal")
        if (modalController) {
          modalController.openWithData({
            title: "Edit Product",
            action: `/products/${productId}`,
            method: "patch",
            resourceId: productId,
            submitText: "Update Product"
          })
          
          // Populate form fields
          const form = modal.querySelector("form")
          if (form) {
            // Basic information
            form.querySelector("#product_name").value = product.name || ""
            form.querySelector("#product_sku").value = product.sku || ""
            form.querySelector("#product_category").value = product.category || ""
            form.querySelector("#product_brand").value = product.brand || ""
            form.querySelector("#product_description").value = product.description || ""
            
            // Pricing & Inventory
            form.querySelector("#product_cost_price").value = product.cost_price || ""
            form.querySelector("#product_selling_price").value = product.selling_price || ""
            form.querySelector("#product_unit_of_measure").value = product.unit_of_measure || "unit"
            form.querySelector("#product_minimum_stock_level").value = product.minimum_stock_level || 0
            form.querySelector("#product_reorder_point").value = product.reorder_point || 0
            
            // Physical Attributes
            form.querySelector("#product_weight").value = product.weight || ""
            form.querySelector("#product_perishable").value = product.perishable ? "true" : "false"
            form.querySelector("#product_length").value = product.length || ""
            form.querySelector("#product_width").value = product.width || ""
            form.querySelector("#product_height").value = product.height || ""
          }
        }
      })
      .catch(error => {
        console.error("Error fetching product:", error)
        this.showToast("Error loading product data. Please try again.", "error")
      })
  }
  
  // View product details
  viewProduct(event) {
    const productId = event.currentTarget.dataset.productId
    if (!productId) return
    
    // Fetch product data
    fetch(`/products/${productId}.json`)
      .then(response => response.json())
      .then(product => {
        // Create a modal with product details - this could be a separate modal
        // For now, we'll reuse the product modal but make fields readonly
        const modal = document.getElementById("product-modal")
        if (!modal) return
        
        // Set modal title and button text
        const modalController = this.application.getControllerForElementAndIdentifier(modal, "modal")
        if (modalController) {
          modalController.openWithData({
            title: "Product Details",
            submitText: "Close",
            cancelText: "Edit"
          })
          
          // Populate form fields
          const form = modal.querySelector("form")
          if (form) {
            // Make all inputs readonly
            form.querySelectorAll("input, textarea, select").forEach(input => {
              input.setAttribute("readonly", true)
              if (input.tagName === "SELECT") {
                input.setAttribute("disabled", true)
              }
            })
            
            // Basic information
            form.querySelector("#product_name").value = product.name || ""
            form.querySelector("#product_sku").value = product.sku || ""
            form.querySelector("#product_category").value = product.category || ""
            form.querySelector("#product_brand").value = product.brand || ""
            form.querySelector("#product_description").value = product.description || ""
            
            // Pricing & Inventory
            form.querySelector("#product_cost_price").value = product.cost_price || ""
            form.querySelector("#product_selling_price").value = product.selling_price || ""
            form.querySelector("#product_unit_of_measure").value = product.unit_of_measure || "unit"
            form.querySelector("#product_minimum_stock_level").value = product.minimum_stock_level || 0
            form.querySelector("#product_reorder_point").value = product.reorder_point || 0
            
            // Physical Attributes
            form.querySelector("#product_weight").value = product.weight || ""
            form.querySelector("#product_perishable").value = product.perishable ? "true" : "false"
            form.querySelector("#product_length").value = product.length || ""
            form.querySelector("#product_width").value = product.width || ""
            form.querySelector("#product_height").value = product.height || ""
          }
        }
      })
      .catch(error => {
        console.error("Error fetching product:", error)
        this.showToast("Error loading product data. Please try again.", "error")
      })
  }
  
  // Open inventory management modal
  manageInventory(event) {
    const productId = event.currentTarget.dataset.productId
    if (!productId) return
    
    // First, open location selector to pick which location to manage inventory for
    const locationModal = document.getElementById("location-selector-modal")
    if (locationModal) {
      const modalController = this.application.getControllerForElementAndIdentifier(locationModal, "modal")
      if (modalController) {
        modalController.open()
        
        // One-time listener for location selection
        const handleLocationSelected = (event) => {
          const location = event.detail.location
          
          // Fetch product and inventory data for this location
          fetch(`/inventory.json?product_id=${productId}&location_id=${location.id}`)
            .then(response => response.json())
            .then(data => {
              const inventoryModal = document.getElementById("inventory-action-modal")
              if (!inventoryModal) return
              
              const inventoryController = this.application.getControllerForElementAndIdentifier(inventoryModal, "modal")
              if (inventoryController) {
                inventoryController.openWithData({
                  title: `Manage Inventory: ${data.product.name}`,
                  action: "/inventory/update",
                  method: "patch",
                  submitText: "Apply Changes"
                })
                
                // Populate the inventory modal with product and location data
                window.populateInventoryModal(
                  productId,
                  data.product.name,
                  location.id,
                  location.name,
                  data.inventory.quantity || 0,
                  data.inventory.available_quantity || 0,
                  data.available_locations
                )
              }
            })
            .catch(error => {
              console.error("Error fetching inventory data:", error)
              this.showToast("Error loading inventory data. Please try again.", "error")
            })
          
          // Remove this one-time listener
          document.removeEventListener("location:selected", handleLocationSelected)
        }
        
        // Listen for location selection
        document.addEventListener("location:selected", handleLocationSelected)
      }
    }
  }
  
  // Show product action menu (more options)
  showProductMenu(event) {
    const productId = event.currentTarget.dataset.productId
    // Implement a dropdown menu with additional actions
  }
  
  // Helper templates and utilities
  loadingTemplate() {
    return `
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
        ${Array(8).fill().map(() => `
          <div class="bg-white dark:bg-gray-800 shadow rounded-lg overflow-hidden animate-pulse">
            <div class="p-4">
              <div class="flex items-center justify-between mb-4">
                <div class="h-6 w-24 bg-gray-200 dark:bg-gray-700 rounded-full"></div>
                <div class="h-6 w-6 bg-gray-200 dark:bg-gray-700 rounded-full"></div>
              </div>
              
              <div class="h-5 bg-gray-200 dark:bg-gray-700 rounded w-3/4 mb-2"></div>
              <div class="h-4 bg-gray-200 dark:bg-gray-700 rounded w-1/2 mb-4"></div>
              
              <div class="grid grid-cols-2 gap-4 mt-4">
                <div>
                  <div class="h-3 bg-gray-200 dark:bg-gray-700 rounded w-12 mb-1"></div>
                  <div class="h-4 bg-gray-200 dark:bg-gray-700 rounded w-16"></div>
                </div>
                <div>
                  <div class="h-3 bg-gray-200 dark:bg-gray-700 rounded w-12 mb-1"></div>
                  <div class="h-4 bg-gray-200 dark:bg-gray-700 rounded w-16"></div>
                </div>
              </div>
            </div>
            
            <div class="border-t border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-750 p-3 flex justify-between">
              <div class="h-5 bg-gray-200 dark:bg-gray-700 rounded w-16"></div>
              <div class="h-5 bg-gray-200 dark:bg-gray-700 rounded w-16"></div>
              <div class="h-5 bg-gray-200 dark:bg-gray-700 rounded w-16"></div>
            </div>
          </div>
        `).join("")}
      </div>
    `
  }
  
  emptyStateTemplate() {
    return `
      <div class="text-center py-12">
        <div class="w-20 h-20 mx-auto bg-gray-100 dark:bg-gray-800 rounded-full flex items-center justify-center text-gray-400 dark:text-gray-500 mb-4">
          <i class="fas fa-box text-2xl"></i>
        </div>
        <h3 class="text-base font-medium text-gray-900 dark:text-white">No products found</h3>
        <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">Get started by creating a new product.</p>
        <button class="mt-4 inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-[#0055A4] hover:bg-[#004890]" data-action="products#createProduct">
          <i class="fas fa-plus mr-2"></i> Add Product
        </button>
      </div>
    `
  }
  
  renderPagination(pagination) {
    if (!this.hasPaginationTarget || !pagination) return
    
    if (pagination.total_pages <= 1) {
      this.paginationTarget.innerHTML = ""
      return
    }
    
    let html = `
      <nav class="flex items-center justify-between px-4 py-3 sm:px-6 bg-white dark:bg-gray-800 rounded-lg shadow mt-4">
        <div class="flex-1 flex justify-between sm:hidden">
          <button ${pagination.current_page === 1 ? 'disabled' : 'data-action="products#changePage"'} data-page="${pagination.current_page - 1}" 
                  class="relative inline-flex items-center px-4 py-2 border border-gray-300 dark:border-gray-600 text-sm font-medium rounded-md ${pagination.current_page === 1 ? 'text-gray-400 dark:text-gray-500 bg-gray-100 dark:bg-gray-800 cursor-not-allowed' : 'text-gray-700 dark:text-gray-300 bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700'}">
            Previous
          </button>
          <button ${pagination.current_page === pagination.total_pages ? 'disabled' : 'data-action="products#changePage"'} data-page="${pagination.current_page + 1}" 
                  class="ml-3 relative inline-flex items-center px-4 py-2 border border-gray-300 dark:border-gray-600 text-sm font-medium rounded-md ${pagination.current_page === pagination.total_pages ? 'text-gray-400 dark:text-gray-500 bg-gray-100 dark:bg-gray-800 cursor-not-allowed' : 'text-gray-700 dark:text-gray-300 bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700'}">
            Next
          </button>
        </div>
        <div class="hidden sm:flex-1 sm:flex sm:items-center sm:justify-between">
          <div>
            <p class="text-sm text-gray-700 dark:text-gray-300">
              Showing <span class="font-medium">${pagination.start_item}</span> to <span class="font-medium">${pagination.end_item}</span> of <span class="font-medium">${pagination.total_items}</span> results
            </p>
          </div>
          <div>
            <nav class="relative z-0 inline-flex rounded-md shadow-sm -space-x-px" aria-label="Pagination">
              <button ${pagination.current_page === 1 ? 'disabled' : 'data-action="products#changePage"'} data-page="${pagination.current_page - 1}" 
                      class="relative inline-flex items-center px-2 py-2 rounded-l-md border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 text-sm font-medium ${pagination.current_page === 1 ? 'text-gray-400 dark:text-gray-500 cursor-not-allowed' : 'text-gray-500 dark:text-gray-400 hover:bg-gray-50 dark:hover:bg-gray-700'}">
                <span class="sr-only">Previous</span>
                <i class="fas fa-chevron-left h-5 w-5"></i>
              </button>
    `
    
    // Determine which page numbers to show
    const pageRange = this.getPageRange(pagination.current_page, pagination.total_pages)
    
    // Add page numbers
    pageRange.forEach(page => {
      if (page === '...') {
        html += `
          <span class="relative inline-flex items-center px-4 py-2 border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 text-sm font-medium text-gray-700 dark:text-gray-300">
            ...
          </span>
        `
      } else {
        html += `
          <button ${page === pagination.current_page ? 'disabled' : 'data-action="products#changePage"'} data-page="${page}" 
                  class="relative inline-flex items-center px-4 py-2 border ${page === pagination.current_page ? 'border-[#0055A4] bg-[#0055A4]/10 text-[#0055A4] dark:text-[#4a9aff] z-10' : 'border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700'} text-sm font-medium">
            ${page}
          </button>
        `
      }
    })
    
    html += `
              <button ${pagination.current_page === pagination.total_pages ? 'disabled' : 'data-action="products#changePage"'} data-page="${pagination.current_page + 1}" 
                      class="relative inline-flex items-center px-2 py-2 rounded-r-md border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 text-sm font-medium ${pagination.current_page === pagination.total_pages ? 'text-gray-400 dark:text-gray-500 cursor-not-allowed' : 'text-gray-500 dark:text-gray-400 hover:bg-gray-50 dark:hover:bg-gray-700'}">
                <span class="sr-only">Next</span>
                <i class="fas fa-chevron-right h-5 w-5"></i>
              </button>
            </nav>
          </div>
        </div>
      </nav>
    `
    
    this.paginationTarget.innerHTML = html
  }
  
  getPageRange(currentPage, totalPages) {
    const range = []
    const maxVisiblePages = 5
    
    if (totalPages <= maxVisiblePages) {
      return Array.from({ length: totalPages }, (_, i) => i + 1)
    }
    
    // Always show first page
    range.push(1)
    
    // Start with ellipsis if needed
    if (currentPage > 3) {
      range.push('...')
    }
    
    // Calculate start and end of range
    let start = Math.max(2, currentPage - 1)
    let end = Math.min(totalPages - 1, currentPage + 1)
    
    // Adjust if at beginning or end
    if (currentPage <= 3) {
      end = Math.min(maxVisiblePages - 1, totalPages - 1)
    } else if (currentPage >= totalPages - 2) {
      start = Math.max(2, totalPages - (maxVisiblePages - 2))
    }
    
    // Add the range
    for (let i = start; i <= end; i++) {
      range.push(i)
    }
    
    // Add end ellipsis if needed
    if (currentPage < totalPages - 2) {
      range.push('...')
    }
    
    // Always show last page
    range.push(totalPages)
    
    return range
  }
  
  getStockStatusInfo(product) {
    if (!product.total_quantity || product.total_quantity <= 0) {
      return {
        label: 'Out of Stock',
        bgClass: 'bg-red-100 dark:bg-red-900/30',
        textClass: 'text-red-700 dark:text-red-400'
      }
    }
    
    if (product.total_quantity <= product.reorder_point) {
      return {
        label: 'Low Stock',
        bgClass: 'bg-amber-100 dark:bg-amber-900/30',
        textClass: 'text-amber-700 dark:text-amber-400'
      }
    }
    
    return {
      label: 'In Stock',
      bgClass: 'bg-green-100 dark:bg-green-900/30',
      textClass: 'text-green-700 dark:text-green-400'
    }
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