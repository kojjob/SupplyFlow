import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  connect() {
    // Initialize the controller
  }

  show(event) {
    const { type, message, duration } = event.detail

    // Create toast element
    const toast = this.createToast(type, message)

    // Add to container
    this.containerTarget.appendChild(toast)

    // Animate in
    setTimeout(() => {
      toast.classList.remove('opacity-0')
      toast.classList.remove('translate-y-4')
    }, 10)

    // Auto remove after duration
    setTimeout(() => {
      this.removeToast(toast)
    }, duration || 5000)
  }

  createToast(type, message) {
    const toast = document.createElement('div')
    toast.className = 'mb-3 p-4 rounded-lg shadow-lg flex items-center transform transition-all duration-300 opacity-0 translate-y-4'

    // Set background color based on type
    switch(type) {
      case 'success':
        toast.classList.add('bg-green-500', 'text-white')
        break
      case 'error':
        toast.classList.add('bg-red-500', 'text-white')
        break
      case 'warning':
        toast.classList.add('bg-amber-500', 'text-white')
        break
      case 'info':
      default:
        toast.classList.add('bg-blue-500', 'text-white')
    }

    // Add icon based on type
    let icon
    switch(type) {
      case 'success':
        icon = '<i class="fas fa-check-circle mr-3 text-xl"></i>'
        break
      case 'error':
        icon = '<i class="fas fa-exclamation-circle mr-3 text-xl"></i>'
        break
      case 'warning':
        icon = '<i class="fas fa-exclamation-triangle mr-3 text-xl"></i>'
        break
      case 'info':
      default:
        icon = '<i class="fas fa-info-circle mr-3 text-xl"></i>'
    }

    // Set content
    toast.innerHTML = `
      ${icon}
      <div class="flex-1">${message}</div>
      <button class="ml-4 text-white opacity-70 hover:opacity-100 transition-opacity duration-200" data-action="click->toast#close">
        <i class="fas fa-times"></i>
      </button>
    `

    return toast
  }

  close(event) {
    const toast = event.currentTarget.closest('div')
    this.removeToast(toast)
  }

  removeToast(toast) {
    toast.classList.add('opacity-0')
    toast.classList.add('translate-y-4')

    setTimeout(() => {
      toast.remove()
    }, 300)
  }

  // Helper methods to be called from other controllers
  success(message, duration = 5000) {
    this.dispatch('show', { detail: { type: 'success', message, duration } })
  }

  error(message, duration = 5000) {
    this.dispatch('show', { detail: { type: 'error', message, duration } })
  }

  warning(message, duration = 5000) {
    this.dispatch('show', { detail: { type: 'warning', message, duration } })
  }

  info(message, duration = 5000) {
    this.dispatch('show', { detail: { type: 'info', message, duration } })
  }
}
