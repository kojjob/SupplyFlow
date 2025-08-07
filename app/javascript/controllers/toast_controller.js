import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]
  static values = {
    position: { type: String, default: "top-right" },
    theme: { type: String, default: "light" }
  }

  connect() {
    // Initialize the controller
    document.addEventListener("toast:show", this.handleCustomToast.bind(this))
    
    // Position the container based on the position value
    this.updateContainerPosition()
    
    // Add theme class to container
    this.updateContainerTheme()
    
    // Load any flash messages on page load
    this.loadFlashMessages()
  }

  disconnect() {
    document.removeEventListener("toast:show", this.handleCustomToast.bind(this))
  }
  
  positionValueChanged() {
    this.updateContainerPosition()
  }
  
  themeValueChanged() {
    this.updateContainerTheme()
  }
  
  updateContainerPosition() {
    // Reset positioning classes
    this.containerTarget.classList.remove(
      'top-0', 'bottom-0', 'left-0', 'right-0',
      'items-start', 'items-end', 'justify-start', 'justify-end', 'justify-center'
    )
    
    // Add positioning classes based on the position value
    switch(this.positionValue) {
      case 'top-left':
        this.containerTarget.classList.add('top-0', 'left-0')
        break
      case 'top-center':
        this.containerTarget.classList.add('top-0', 'left-1/2', '-translate-x-1/2')
        break
      case 'top-right':
        this.containerTarget.classList.add('top-0', 'right-0')
        break
      case 'bottom-left':
        this.containerTarget.classList.add('bottom-0', 'left-0')
        break
      case 'bottom-center':
        this.containerTarget.classList.add('bottom-0', 'left-1/2', '-translate-x-1/2')
        break
      case 'bottom-right':
        this.containerTarget.classList.add('bottom-0', 'right-0')
        break
      case 'center':
        this.containerTarget.classList.add('top-1/2', 'left-1/2', '-translate-x-1/2', '-translate-y-1/2')
        break
    }
  }
  
  updateContainerTheme() {
    // Remove theme classes
    this.containerTarget.classList.remove('toast-theme-light', 'toast-theme-dark')
    
    // Add theme class
    this.containerTarget.classList.add(`toast-theme-${this.themeValue}`)
  }
  
  loadFlashMessages() {
    // Get flash messages from data attributes on the body
    const flashMessages = document.body.dataset.flashMessages
    
    if (flashMessages) {
      try {
        const messages = JSON.parse(flashMessages)
        Object.entries(messages).forEach(([type, message]) => {
          if (message) {
            setTimeout(() => {
              this.show({ detail: { type, message } })
            }, 300) // Small delay to ensure the animation works
          }
        })
      } catch (e) {
        console.error('Error parsing flash messages:', e)
      }
    }
  }

  handleCustomToast(event) {
    const { message, type, title, actions, duration, position } = event.detail
    
    // If position is provided in the event, temporarily override the container position
    if (position && position !== this.positionValue) {
      const originalPosition = this.positionValue
      this.positionValue = position
      
      // Reset back to original position after the toast is shown
      setTimeout(() => {
        this.positionValue = originalPosition
      }, 100)
    }
    
    this.dispatch('show', { detail: { type, message, title, actions, duration } })
  }

  show(event) {
    const { type, message, title, actions, duration } = event.detail

    // Create toast element
    const toast = this.createToast(type, message, title, actions)

    // Add to container
    this.containerTarget.appendChild(toast)

    // Animate in
    setTimeout(() => {
      toast.classList.remove('opacity-0')
      toast.classList.remove('translate-y-4', '-translate-y-4')
    }, 10)

    // Auto remove after duration
    const toastDuration = duration || 5000
    if (toastDuration > 0) {
      // Add progress bar
      const progressBar = document.createElement('div')
      progressBar.className = 'absolute bottom-0 left-0 h-1 transition-all duration-100 ease-linear progress-bar'
      
      // Set progress bar color based on type
      switch(type) {
        case 'success':
          progressBar.classList.add('bg-green-600')
          break
        case 'error':
          progressBar.classList.add('bg-red-600')
          break
        case 'warning':
          progressBar.classList.add('bg-amber-600')
          break
        case 'info':
        default:
          progressBar.classList.add('bg-blue-600')
      }
      
      toast.appendChild(progressBar)
      
      // Animate progress bar
      let width = 100
      const interval = toastDuration / 100
      const timer = setInterval(() => {
        width -= 1
        progressBar.style.width = `${width}%`
        
        if (width <= 0) {
          clearInterval(timer)
        }
      }, interval)
      
      setTimeout(() => {
        clearInterval(timer)
        this.removeToast(toast)
      }, toastDuration)
    }
    
    // Add hover pause effect
    toast.addEventListener('mouseenter', () => {
      toast.classList.add('toast-paused')
      // Pause progress bar animation
      const progressBar = toast.querySelector('.progress-bar')
      if (progressBar) {
        progressBar.style.animationPlayState = 'paused'
      }
    })
    
    toast.addEventListener('mouseleave', () => {
      toast.classList.remove('toast-paused')
      // Resume progress bar animation
      const progressBar = toast.querySelector('.progress-bar')
      if (progressBar) {
        progressBar.style.animationPlayState = 'running'
      }
    })
  }

  createToast(type, message, title, actions) {
    const isDarkTheme = this.themeValue === 'dark'
    const toast = document.createElement('div')
    toast.className = 'mb-3 rounded-lg shadow-xl flex flex-col transform transition-all duration-300 opacity-0 max-w-md overflow-hidden relative'
    
    // Animation: Different animation based on position
    if (this.positionValue.startsWith('top')) {
      toast.classList.add('-translate-y-4')
    } else if (this.positionValue.startsWith('bottom')) {
      toast.classList.add('translate-y-4')
    }
    
    // Set colors based on type and theme
    if (isDarkTheme) {
      toast.classList.add('bg-gray-800', 'text-white', 'border-l-4')
      
      switch(type) {
        case 'success':
          toast.classList.add('border-green-500')
          break
        case 'error':
          toast.classList.add('border-red-500')
          break
        case 'warning':
          toast.classList.add('border-amber-500')
          break
        case 'info':
        default:
          toast.classList.add('border-blue-500')
      }
    } else {
      toast.classList.add('bg-white', 'text-gray-800', 'border-l-4')
      
      switch(type) {
        case 'success':
          toast.classList.add('border-green-500')
          break
        case 'error':
          toast.classList.add('border-red-500')
          break
        case 'warning':
          toast.classList.add('border-amber-500')
          break
        case 'info':
        default:
          toast.classList.add('border-blue-500')
      }
    }

    // Create header with icon and title
    const header = document.createElement('div')
    header.className = 'flex items-center p-4 pb-2'
    
    // Add icon based on type
    let icon
    switch(type) {
      case 'success':
        icon = '<i class="fas fa-check-circle text-green-500 mr-3 text-xl"></i>'
        break
      case 'error':
        icon = '<i class="fas fa-exclamation-circle text-red-500 mr-3 text-xl"></i>'
        break
      case 'warning':
        icon = '<i class="fas fa-exclamation-triangle text-amber-500 mr-3 text-xl"></i>'
        break
      case 'info':
      default:
        icon = '<i class="fas fa-info-circle text-blue-500 mr-3 text-xl"></i>'
    }
    
    header.innerHTML = icon
    
    // Add title if provided, otherwise use type as title
    const titleEl = document.createElement('div')
    titleEl.className = 'font-bold flex-1'
    titleEl.textContent = title || this.capitalizeFirstLetter(type)
    header.appendChild(titleEl)
    
    // Add close button
    const closeButton = document.createElement('button')
    closeButton.className = `${isDarkTheme ? 'text-gray-400' : 'text-gray-500'} hover:text-gray-700 transition-colors duration-200`
    closeButton.setAttribute('data-action', 'click->toast#close')
    closeButton.innerHTML = '<i class="fas fa-times"></i>'
    header.appendChild(closeButton)
    
    toast.appendChild(header)
    
    // Add message content
    if (message) {
      const content = document.createElement('div')
      content.className = 'px-4 py-2 text-sm'
      
      // Support HTML content if message contains HTML tags
      if (/<[a-z][\s\S]*>/i.test(message)) {
        content.innerHTML = message
      } else {
        content.textContent = message
      }
      
      toast.appendChild(content)
    }
    
    // Add action buttons if provided
    if (actions && actions.length) {
      const actionsContainer = document.createElement('div')
      actionsContainer.className = 'flex justify-end p-2 space-x-2'
      
      actions.forEach(action => {
        const button = document.createElement('button')
        button.textContent = action.text
        button.className = 'px-3 py-1 rounded text-sm font-medium'
        
        // Set button style based on type
        if (action.primary) {
          switch(type) {
            case 'success':
              button.classList.add('bg-green-500', 'hover:bg-green-600', 'text-white')
              break
            case 'error':
              button.classList.add('bg-red-500', 'hover:bg-red-600', 'text-white')
              break
            case 'warning':
              button.classList.add('bg-amber-500', 'hover:bg-amber-600', 'text-white')
              break
            case 'info':
            default:
              button.classList.add('bg-blue-500', 'hover:bg-blue-600', 'text-white')
          }
        } else {
          button.classList.add(
            isDarkTheme ? 'bg-gray-700 hover:bg-gray-600 text-white' : 'bg-gray-200 hover:bg-gray-300 text-gray-800'
          )
        }
        
        // Add click handler
        button.addEventListener('click', () => {
          if (action.callback && typeof action.callback === 'function') {
            action.callback()
          }
          this.removeToast(toast)
        })
        
        actionsContainer.appendChild(button)
      })
      
      toast.appendChild(actionsContainer)
    }
    
    return toast
  }

  close(event) {
    const toast = event.currentTarget.closest('div[class*="rounded-lg"]')
    this.removeToast(toast)
  }

  removeToast(toast) {
    toast.classList.add('opacity-0')
    
    // Apply proper transformation based on position
    if (this.positionValue.startsWith('top')) {
      toast.classList.add('-translate-y-4')
    } else if (this.positionValue.startsWith('bottom')) {
      toast.classList.add('translate-y-4')
    }

    setTimeout(() => {
      toast.remove()
    }, 300)
  }
  
  capitalizeFirstLetter(string) {
    return string.charAt(0).toUpperCase() + string.slice(1)
  }

  // Helper methods to be called from other controllers
  success(message, options = {}) {
    const detail = { 
      type: 'success', 
      message, 
      title: options.title,
      actions: options.actions,
      duration: options.duration || 5000,
      position: options.position
    }
    this.dispatch('show', { detail })
  }

  error(message, options = {}) {
    const detail = { 
      type: 'error', 
      message, 
      title: options.title || 'Error',
      actions: options.actions,
      duration: options.duration || 8000,
      position: options.position
    }
    this.dispatch('show', { detail })
  }

  warning(message, options = {}) {
    const detail = { 
      type: 'warning', 
      message, 
      title: options.title || 'Warning',
      actions: options.actions,
      duration: options.duration || 7000,
      position: options.position
    }
    this.dispatch('show', { detail })
  }

  info(message, options = {}) {
    const detail = { 
      type: 'info', 
      message, 
      title: options.title || 'Information',
      actions: options.actions,
      duration: options.duration || 5000,
      position: options.position
    }
    this.dispatch('show', { detail })
  }
}
