import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "container", "messages", "input"]

  connect() {
    // Initialize the controller
    this.isOpen = false
    this.messages = []
    
    // Predefined responses for demo purposes
    this.responses = {
      "inventory management": "Our inventory management system allows you to track stock levels, set up low stock alerts, and generate reports. What specific feature are you interested in?",
      "billing question": "I'd be happy to help with your billing question. Could you please provide more details about your inquiry?",
      "technical support": "For technical support, I'll need to know what issue you're experiencing. Could you describe the problem in detail?",
      "default": "Thank you for your message. One of our support agents will respond shortly. Is there anything else you'd like to know in the meantime?"
    }
  }
  
  open() {
    // Show the overlay
    this.overlayTarget.classList.remove("hidden")
    
    // Animate the container
    setTimeout(() => {
      if (window.innerWidth >= 768) {
        // Desktop animation
        this.containerTarget.classList.remove("scale-0")
        this.containerTarget.classList.add("scale-100")
      } else {
        // Mobile animation
        this.containerTarget.classList.remove("translate-y-full")
        this.containerTarget.classList.add("translate-y-0")
      }
    }, 50)
    
    this.isOpen = true
    
    // Focus the input field
    setTimeout(() => {
      this.inputTarget.focus()
    }, 500)
  }
  
  close() {
    // Animate the container
    if (window.innerWidth >= 768) {
      // Desktop animation
      this.containerTarget.classList.remove("scale-100")
      this.containerTarget.classList.add("scale-0")
    } else {
      // Mobile animation
      this.containerTarget.classList.remove("translate-y-0")
      this.containerTarget.classList.add("translate-y-full")
    }
    
    // Hide the overlay after animation
    setTimeout(() => {
      this.overlayTarget.classList.add("hidden")
    }, 300)
    
    this.isOpen = false
  }
  
  sendMessage(event) {
    event.preventDefault()
    
    const message = this.inputTarget.value.trim()
    if (!message) return
    
    // Add user message to chat
    this.addUserMessage(message)
    
    // Clear input
    this.inputTarget.value = ""
    
    // Simulate response after a short delay
    setTimeout(() => {
      this.addAgentResponse(this.getResponse(message))
    }, 1000)
  }
  
  sendQuickReply(event) {
    const message = event.currentTarget.dataset.message
    
    // Add user message to chat
    this.addUserMessage(message)
    
    // Remove quick reply options
    const quickReplies = this.messagesTarget.querySelector('.flex.flex-wrap.gap-2')
    if (quickReplies) {
      quickReplies.remove()
    }
    
    // Simulate response after a short delay
    setTimeout(() => {
      this.addAgentResponse(this.getResponse(message.toLowerCase()))
    }, 1000)
  }
  
  addUserMessage(message) {
    const html = `
      <div class="flex justify-end mb-4">
        <div class="bg-[#0055A4] rounded-lg p-3 max-w-[80%] text-white">
          <p class="text-sm">${this.escapeHTML(message)}</p>
          <span class="text-xs text-white/70 mt-1 block">Just now</span>
        </div>
        <div class="w-8 h-8 rounded-full bg-[#0055A4] flex items-center justify-center text-white ml-2 flex-shrink-0">
          <i class="fas fa-user text-sm"></i>
        </div>
      </div>
    `
    
    this.messagesTarget.insertAdjacentHTML('beforeend', html)
    this.scrollToBottom()
  }
  
  addAgentResponse(message) {
    const html = `
      <div class="flex mb-4">
        <div class="w-8 h-8 rounded-full bg-[#0055A4] flex items-center justify-center text-white mr-2 flex-shrink-0">
          <i class="fas fa-headset text-sm"></i>
        </div>
        <div class="bg-gray-100 dark:bg-gray-700 rounded-lg p-3 max-w-[80%]">
          <p class="text-gray-800 dark:text-white text-sm">${message}</p>
          <span class="text-xs text-gray-500 dark:text-gray-400 mt-1 block">Just now</span>
        </div>
      </div>
    `
    
    this.messagesTarget.insertAdjacentHTML('beforeend', html)
    this.scrollToBottom()
    
    // Add typing indicator
    this.addTypingIndicator()
    
    // Remove typing indicator after 2 seconds and add follow-up message
    setTimeout(() => {
      this.removeTypingIndicator()
      
      const followUpHtml = `
        <div class="flex mb-4">
          <div class="w-8 h-8 rounded-full bg-[#0055A4] flex items-center justify-center text-white mr-2 flex-shrink-0">
            <i class="fas fa-headset text-sm"></i>
          </div>
          <div class="bg-gray-100 dark:bg-gray-700 rounded-lg p-3 max-w-[80%]">
            <p class="text-gray-800 dark:text-white text-sm">Is there anything else I can help you with today?</p>
            <span class="text-xs text-gray-500 dark:text-gray-400 mt-1 block">Just now</span>
          </div>
        </div>
      `
      
      this.messagesTarget.insertAdjacentHTML('beforeend', followUpHtml)
      this.scrollToBottom()
    }, 2000)
  }
  
  addTypingIndicator() {
    const html = `
      <div class="flex mb-4 typing-indicator">
        <div class="w-8 h-8 rounded-full bg-[#0055A4] flex items-center justify-center text-white mr-2 flex-shrink-0">
          <i class="fas fa-headset text-sm"></i>
        </div>
        <div class="bg-gray-100 dark:bg-gray-700 rounded-lg p-3">
          <div class="flex space-x-1">
            <div class="w-2 h-2 bg-gray-400 dark:bg-gray-500 rounded-full animate-bounce"></div>
            <div class="w-2 h-2 bg-gray-400 dark:bg-gray-500 rounded-full animate-bounce" style="animation-delay: 0.2s"></div>
            <div class="w-2 h-2 bg-gray-400 dark:bg-gray-500 rounded-full animate-bounce" style="animation-delay: 0.4s"></div>
          </div>
        </div>
      </div>
    `
    
    this.messagesTarget.insertAdjacentHTML('beforeend', html)
    this.scrollToBottom()
  }
  
  removeTypingIndicator() {
    const indicator = this.messagesTarget.querySelector('.typing-indicator')
    if (indicator) {
      indicator.remove()
    }
  }
  
  getResponse(message) {
    message = message.toLowerCase()
    
    if (message.includes("inventory") || message.includes("stock") || message.includes("inventory management")) {
      return this.responses["inventory management"]
    } else if (message.includes("bill") || message.includes("payment") || message.includes("billing question")) {
      return this.responses["billing question"]
    } else if (message.includes("technical") || message.includes("support") || message.includes("help") || message.includes("technical support")) {
      return this.responses["technical support"]
    } else {
      return this.responses["default"]
    }
  }
  
  scrollToBottom() {
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }
  
  escapeHTML(html) {
    const div = document.createElement('div')
    div.textContent = html
    return div.innerHTML
  }
}
