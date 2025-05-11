import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "mobileContainer", "desktopContainer", "messages", "desktopMessages", "input", "desktopInput"]

  connect() {
    // Initialize the controller
    this.isOpen = false
    this.conversationHistory = []
    this.currentContext = null
    this.lastQuery = null
    
    // Knowledge base about available features
    this.features = {
      inventory: {
        manageStock: "track and manage inventory levels across all locations",
        lowStockAlerts: "set up notifications when products reach reorder points",
        transfers: "transfer inventory between locations",
        reports: "generate inventory reports",
        batchOperations: "perform bulk inventory operations"
      },
      products: {
        categories: "organize products by category",
        pricing: "set cost and selling prices with profit margins",
        dimensions: "track product dimensions and weight",
        reorderPoints: "set minimum stock levels and reorder points",
        search: "search and filter products by various attributes"
      },
      locations: {
        management: "create and manage multiple locations",
        hierarchy: "set up parent-child relationships between locations",
        stock: "view stock levels at each location"
      },
      users: {
        roles: "assign different permission levels to users",
        activity: "track user activity in the system"
      }
    }

    // Enhanced responses with follow-up questions and context awareness
    this.responses = {
      "inventory management": {
        general: "Our inventory management system allows you to track stock levels, set up low stock alerts, and generate reports. What specific feature are you interested in?",
        features: ["Stock tracking", "Low stock alerts", "Inventory transfers", "Reports", "Batch operations"],
        followUp: {
          "stock tracking": "You can track inventory across all your locations. Would you like to know how to view current stock levels or update them?",
          "low stock alerts": "Low stock alerts notify you when products reach their reorder points. Would you like to know how to set up these alerts?",
          "inventory transfers": "You can transfer inventory between locations easily. Would you like to know how to perform a transfer?",
          "reports": "Our reporting system provides insights into your inventory. What type of report are you interested in? Stock levels, movement history, or valuation?",
          "batch operations": "Batch operations allow you to update multiple inventory items at once. Would you like to know how to perform batch additions or removals?"
        },
        context: "inventory"
      },
      "product management": {
        general: "Our product management system allows you to create, edit and organize your products with detailed information. What would you like to know about managing products?",
        features: ["Adding products", "Categories", "Pricing", "Dimensions", "Reorder points"],
        followUp: {
          "adding products": "You can add new products with details like SKU, name, description, pricing, and dimensions. Would you like step-by-step instructions?",
          "categories": "Categories help organize your products for easier management. Would you like to know how to create or manage categories?",
          "pricing": "You can set both cost and selling prices, with automatic profit margin calculation. Would you like to know how to set up pricing?",
          "dimensions": "Tracking dimensions helps with shipping and storage planning. Would you like to know how to add dimension data?",
          "reorder points": "Reorder points trigger low stock alerts. Would you like to know how to set reorder points for your products?"
        },
        context: "products"
      },
      "location management": {
        general: "Our location management features allow you to manage multiple warehouses, stores, or storage areas. What would you like to know about managing locations?",
        features: ["Adding locations", "Location hierarchy", "Viewing stock by location"],
        followUp: {
          "adding locations": "You can add new locations with details like name, address, and type. Would you like step-by-step instructions?",
          "location hierarchy": "You can create parent-child relationships between locations. Would you like to know how to set up a location hierarchy?",
          "viewing stock by location": "You can view current stock levels at each location. Would you like to know how to access this information?"
        },
        context: "locations"
      },
      "billing question": {
        general: "I'd be happy to help with your billing question. What specific aspect of billing would you like to know about?",
        features: ["Subscription plans", "Payment methods", "Invoices", "Billing cycles"],
        followUp: {
          "subscription plans": "We offer several subscription tiers based on your business needs. Would you like to see our current pricing plans?",
          "payment methods": "We accept credit cards, bank transfers, and mobile money. Would you like information on adding a payment method?",
          "invoices": "You can view and download all past invoices from your account. Would you like to know how to access your invoice history?",
          "billing cycles": "Billing occurs monthly or annually depending on your plan. Would you like more information about our billing cycles?"
        },
        context: "billing"
      },
      "technical support": {
        general: "For technical support, I'll need to know what issue you're experiencing. Could you please describe the problem in more detail?",
        features: ["Login issues", "System errors", "Feature requests", "Performance problems"],
        followUp: {
          "login issues": "I can help with login problems. Are you having trouble accessing your account or resetting your password?",
          "system errors": "I can help troubleshoot system errors. Are you seeing any specific error messages or codes?",
          "feature requests": "We welcome feature suggestions! Could you describe the functionality you'd like to see added?",
          "performance problems": "I can help with performance issues. Is the system running slowly or are specific functions not responding?"
        },
        context: "support"
      },
      "default": {
        general: "Thank you for your message. I'm here to help with inventory management, product information, locations, billing, and technical support. What would you like assistance with?",
        features: ["Inventory management", "Product management", "Location management", "Billing", "Technical support"],
        context: null
      }
    }
  }

  open() {
    console.log("Opening chat widget")

    // Show the overlay
    this.overlayTarget.classList.remove("hidden")

    // Determine if we're on mobile or desktop
    const isMobile = window.innerWidth < 768

    if (isMobile) {
      console.log("Opening mobile chat")
      // Mobile animation
      setTimeout(() => {
        this.mobileContainerTarget.classList.remove("translate-y-full")
        this.mobileContainerTarget.classList.add("translate-y-0")
      }, 50)

      // Focus the input field
      setTimeout(() => {
        if (this.hasInputTarget) {
          this.inputTarget.focus()
        }
      }, 500)
    } else {
      console.log("Opening desktop chat")
      // Desktop animation
      setTimeout(() => {
        this.desktopContainerTarget.classList.remove("scale-0", "opacity-0")
        this.desktopContainerTarget.classList.add("scale-100", "opacity-100")
      }, 50)

      // Focus the desktop input field
      setTimeout(() => {
        if (this.hasDesktopInputTarget) {
          this.desktopInputTarget.focus()
        }
      }, 500)
    }

    this.isOpen = true
  }

  close() {
    // Determine if we're on mobile or desktop
    const isMobile = window.innerWidth < 768

    if (isMobile) {
      // Mobile animation
      this.mobileContainerTarget.classList.remove("translate-y-0")
      this.mobileContainerTarget.classList.add("translate-y-full")
    } else {
      // Desktop animation
      this.desktopContainerTarget.classList.remove("scale-100", "opacity-100")
      this.desktopContainerTarget.classList.add("scale-0", "opacity-0")
    }

    // Hide the overlay after animation
    setTimeout(() => {
      this.overlayTarget.classList.add("hidden")
    }, 300)

    this.isOpen = false
  }

  sendMessage(event) {
    event.preventDefault()

    // Determine if the message is from mobile or desktop
    const isMobile = window.innerWidth < 768
    const input = isMobile ? this.inputTarget : this.desktopInputTarget
    const message = input.value.trim()

    if (!message) return

    // Add user message to chat
    this.addUserMessage(message)

    // Store in conversation history
    this.conversationHistory.push({
      type: 'user',
      message: message,
      timestamp: new Date()
    })
    
    this.lastQuery = message.toLowerCase()

    // Clear input
    input.value = ""

    // Simulate response after a short delay
    setTimeout(() => {
      const response = this.getIntelligentResponse(message)
      this.addAgentResponse(response.message)
      
      // Store agent response in history
      this.conversationHistory.push({
        type: 'agent',
        message: response.message,
        context: response.context,
        timestamp: new Date()
      })
      
      // Update current context if a new one was set
      if (response.context) {
        this.currentContext = response.context
      }
      
      // Add quick reply buttons if available
      if (response.quickReplies && response.quickReplies.length > 0) {
        setTimeout(() => {
          this.addQuickReplyOptions(response.quickReplies)
        }, 500)
      }
    }, 1000)
  }

  sendQuickReply(event) {
    const message = event.currentTarget.dataset.message

    // Add user message to chat
    this.addUserMessage(message)
    
    // Store in conversation history
    this.conversationHistory.push({
      type: 'user',
      message: message,
      timestamp: new Date()
    })
    
    this.lastQuery = message.toLowerCase()

    // Remove quick reply options from both mobile and desktop
    if (this.hasMessagesTarget) {
      const quickReplies = this.messagesTarget.querySelector('.flex.flex-wrap.gap-2')
      if (quickReplies) {
        quickReplies.remove()
      }
    }

    if (this.hasDesktopMessagesTarget) {
      const quickReplies = this.desktopMessagesTarget.querySelector('.flex.flex-wrap.gap-2')
      if (quickReplies) {
        quickReplies.remove()
      }
    }

    // Simulate response after a short delay
    setTimeout(() => {
      const response = this.getIntelligentResponse(message)
      this.addAgentResponse(response.message)
      
      // Store agent response in history
      this.conversationHistory.push({
        type: 'agent',
        message: response.message,
        context: response.context,
        timestamp: new Date()
      })
      
      // Update current context if a new one was set
      if (response.context) {
        this.currentContext = response.context
      }
      
      // Add quick reply buttons if available
      if (response.quickReplies && response.quickReplies.length > 0) {
        setTimeout(() => {
          this.addQuickReplyOptions(response.quickReplies)
        }, 500)
      }
    }, 1000)
  }
  
  addQuickReplyOptions(options) {
    if (!options || options.length === 0) return
    
    let html = '<div class="flex flex-wrap gap-2 mb-4 ml-10">'
    
    options.forEach(option => {
      html += `
        <button data-action="chat-widget#sendQuickReply" data-message="${option}" class="bg-gray-100 dark:bg-gray-700 hover:bg-[#0055A4]/10 dark:hover:bg-[#0055A4]/20 text-gray-800 dark:text-white text-sm py-2 px-3 rounded-full transition-colors duration-200">
          ${option}
        </button>
      `
    })
    
    html += '</div>'
    
    // Add to both mobile and desktop messages
    if (this.hasMessagesTarget) {
      this.messagesTarget.insertAdjacentHTML('beforeend', html)
      this.scrollToBottom(this.messagesTarget)
    }

    if (this.hasDesktopMessagesTarget) {
      this.desktopMessagesTarget.insertAdjacentHTML('beforeend', html)
      this.scrollToBottom(this.desktopMessagesTarget)
    }
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

    // Add to both mobile and desktop messages
    if (this.hasMessagesTarget) {
      this.messagesTarget.insertAdjacentHTML('beforeend', html)
      this.scrollToBottom(this.messagesTarget)
    }

    if (this.hasDesktopMessagesTarget) {
      this.desktopMessagesTarget.insertAdjacentHTML('beforeend', html)
      this.scrollToBottom(this.desktopMessagesTarget)
    }
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

    // Add to both mobile and desktop messages
    if (this.hasMessagesTarget) {
      this.messagesTarget.insertAdjacentHTML('beforeend', html)
      this.scrollToBottom(this.messagesTarget)
    }

    if (this.hasDesktopMessagesTarget) {
      this.desktopMessagesTarget.insertAdjacentHTML('beforeend', html)
      this.scrollToBottom(this.desktopMessagesTarget)
    }

    // Only add typing indicator and follow-up for final responses
    // Quick replies will handle the conversation flow for intermediate responses
    if (!this.conversationHistory || this.conversationHistory.length < 2) {
      this.addTypingIndicatorWithFollowUp(this.getDefaultFollowUp())
      return
    }
    
    // Get personalized follow-up based on context
    const followUp = this.getPersonalizedFollowUp()
    this.addTypingIndicatorWithFollowUp(followUp)
  }
  
  addTypingIndicatorWithFollowUp(followUpMessage) {
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
            <p class="text-gray-800 dark:text-white text-sm">${followUpMessage}</p>
            <span class="text-xs text-gray-500 dark:text-gray-400 mt-1 block">Just now</span>
          </div>
        </div>
      `

      // Add to both mobile and desktop messages
      if (this.hasMessagesTarget) {
        this.messagesTarget.insertAdjacentHTML('beforeend', followUpHtml)
        this.scrollToBottom(this.messagesTarget)
      }

      if (this.hasDesktopMessagesTarget) {
        this.desktopMessagesTarget.insertAdjacentHTML('beforeend', followUpHtml)
        this.scrollToBottom(this.desktopMessagesTarget)
      }
    }, 2000)
  }
  
  getDefaultFollowUp() {
    return "Is there anything else I can help you with today?"
  }
  
  getPersonalizedFollowUp() {
    // If no context, use default
    if (!this.currentContext) {
      return this.getDefaultFollowUp()
    }
    
    // Get conversation metrics
    const messageCount = this.conversationHistory.length
    const userMessages = this.conversationHistory.filter(msg => msg.type === 'user')
    const lastUserMessage = userMessages[userMessages.length - 1]
    
    // Check if this is a new conversation (fewer than 4 messages total)
    const isNewConversation = messageCount < 4
    
    // Check if user is asking many questions (more than 3 user messages)
    const isInquisitive = userMessages.length > 3
    
    // Personalized follow-ups based on context and conversation state
    switch (this.currentContext) {
      case "inventory":
        if (isNewConversation) {
          return "Would you like to learn more about our inventory management features? I can tell you about stock tracking, low stock alerts, or inventory transfers."
        } else if (isInquisitive) {
          return "You seem interested in inventory management! Would you like me to show you a step-by-step guide to setting up your inventory system?"
        } else {
          return "Is there a specific inventory challenge you're trying to solve? I'm here to help."
        }
        
      case "products":
        if (isNewConversation) {
          return "Would you like to know more about how to organize your products or set up pricing?"
        } else if (isInquisitive) {
          return "Product management is a key part of SupplyFlow. Would you like to see how our product features work together with inventory management?"
        } else {
          return "Do you need help with anything specific about your products or catalog management?"
        }
        
      case "locations":
        if (isNewConversation) {
          return "Would you like to learn about setting up your first location or creating a location hierarchy?"
        } else if (isInquisitive) {
          return "I see you're interested in location management! Would you like me to explain how locations work with inventory transfers?"
        } else {
          return "Is there anything specific about location management you'd like to know more about?"
        }
        
      case "billing":
        return "Is there anything else about our billing system you'd like to know? I'm happy to explain our subscription plans or payment options."
        
      case "support":
        return "Is there anything else I can help troubleshoot for you today? I'm here to help resolve any issues you're experiencing."
        
      default:
        return this.getDefaultFollowUp()
    }
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

    // Add to both mobile and desktop messages
    if (this.hasMessagesTarget) {
      this.messagesTarget.insertAdjacentHTML('beforeend', html)
      this.scrollToBottom(this.messagesTarget)
    }

    if (this.hasDesktopMessagesTarget) {
      this.desktopMessagesTarget.insertAdjacentHTML('beforeend', html)
      this.scrollToBottom(this.desktopMessagesTarget)
    }
  }

  removeTypingIndicator() {
    // Remove from mobile
    if (this.hasMessagesTarget) {
      const indicator = this.messagesTarget.querySelector('.typing-indicator')
      if (indicator) {
        indicator.remove()
      }
    }

    // Remove from desktop
    if (this.hasDesktopMessagesTarget) {
      const indicator = this.desktopMessagesTarget.querySelector('.typing-indicator')
      if (indicator) {
        indicator.remove()
      }
    }
  }

  getIntelligentResponse(message) {
    message = message.toLowerCase()
    
    // Analyze the message with NLP techniques
    const analysis = this.analyzeMessage(message)
    
    // First, check if this is a follow-up to a previous context
    if (this.currentContext && this.conversationHistory.length > 1) {
      const responseData = this.handleContextualQuery(message, analysis)
      if (responseData) return responseData
    }
    
    // If not a contextual follow-up or no context was found, treat as a new query
    let responseKey = "default"
    let confidenceScore = 0
    
    // Check for inventory management topics
    if (analysis.intents.inventory > 0.5) {
      responseKey = "inventory management"
      confidenceScore = analysis.intents.inventory
    } 
    // Check for product management topics
    else if (analysis.intents.products > 0.5) {
      responseKey = "product management"
      confidenceScore = analysis.intents.products
    }
    // Check for location management topics
    else if (analysis.intents.locations > 0.5) {
      responseKey = "location management"
      confidenceScore = analysis.intents.locations
    }
    // Check for billing questions
    else if (analysis.intents.billing > 0.5) {
      responseKey = "billing question"
      confidenceScore = analysis.intents.billing
    }
    // Check for technical support
    else if (analysis.intents.support > 0.5) {
      responseKey = "technical support"
      confidenceScore = analysis.intents.support
    }
    
    // Get response data for the identified intent
    const responseData = this.responses[responseKey]
    
    // Return a structured response object
    return {
      message: responseData.general,
      context: responseData.context,
      confidenceScore: confidenceScore,
      quickReplies: responseData.features
    }
  }
  
  // Analyze message using basic NLP techniques
  analyzeMessage(message) {
    message = message.toLowerCase()
    
    // Intent classification using keyword matching and scoring
    const intents = {
      inventory: 0,
      products: 0,
      locations: 0,
      billing: 0,
      support: 0
    }
    
    // Inventory management keywords
    const inventoryKeywords = [
      "inventory", "stock", "level", "warehouse", "alert", "reorder", "low stock",
      "transfer", "batch", "add stock", "remove stock", "stock movement", "report"
    ]
    
    // Product management keywords
    const productKeywords = [
      "product", "item", "sku", "category", "price", "cost", "selling", "margin",
      "dimension", "weight", "height", "width", "length", "add product", "edit product"
    ]
    
    // Location management keywords
    const locationKeywords = [
      "location", "warehouse", "store", "branch", "outlet", "add location", 
      "parent", "child", "hierarchy", "address"
    ]
    
    // Billing keywords
    const billingKeywords = [
      "bill", "billing", "invoice", "payment", "subscription", "plan", "price", 
      "cost", "charge", "fee", "pay", "credit", "debit", "transaction"
    ]
    
    // Support keywords
    const supportKeywords = [
      "help", "support", "technical", "issue", "problem", "error", "bug", "fix",
      "broken", "not working", "assistance", "guide", "how to", "trouble"
    ]
    
    // Calculate intent scores based on keyword matches
    inventoryKeywords.forEach(keyword => {
      if (message.includes(keyword)) {
        intents.inventory += 0.2
      }
    })
    
    productKeywords.forEach(keyword => {
      if (message.includes(keyword)) {
        intents.products += 0.2
      }
    })
    
    locationKeywords.forEach(keyword => {
      if (message.includes(keyword)) {
        intents.locations += 0.2
      }
    })
    
    billingKeywords.forEach(keyword => {
      if (message.includes(keyword)) {
        intents.billing += 0.2
      }
    })
    
    supportKeywords.forEach(keyword => {
      if (message.includes(keyword)) {
        intents.support += 0.2
      }
    })
    
    // Check for direct intent expressions
    if (message.includes("inventory management") || message.includes("manage inventory")) {
      intents.inventory = 1.0
    }
    
    if (message.includes("product management") || message.includes("manage products")) {
      intents.products = 1.0
    }
    
    if (message.includes("location management") || message.includes("manage locations")) {
      intents.locations = 1.0
    }
    
    if (message.includes("billing question") || message.includes("about billing")) {
      intents.billing = 1.0
    }
    
    if (message.includes("technical support") || message.includes("technical help")) {
      intents.support = 1.0
    }
    
    // Cap scores at 1.0
    Object.keys(intents).forEach(key => {
      intents[key] = Math.min(intents[key], 1.0)
    })
    
    // Extract entities (specific items mentioned)
    const entities = {
      products: [],
      locations: [],
      features: []
    }
    
    // Extract inventory-related features
    if (message.includes("low stock")) entities.features.push("low stock alerts")
    if (message.includes("transfer")) entities.features.push("inventory transfers")
    if (message.includes("report")) entities.features.push("reports")
    if (message.includes("batch")) entities.features.push("batch operations")
    
    // Extract product-related features
    if (message.includes("add product")) entities.features.push("adding products")
    if (message.includes("categor")) entities.features.push("categories")
    if (message.includes("price") || message.includes("cost") || message.includes("margin")) {
      entities.features.push("pricing")
    }
    if (message.includes("dimension") || message.includes("weight") || 
        message.includes("height") || message.includes("width") || message.includes("length")) {
      entities.features.push("dimensions")
    }
    if (message.includes("reorder") || message.includes("minimum stock")) {
      entities.features.push("reorder points")
    }
    
    // Extract location-related features
    if (message.includes("add location")) entities.features.push("adding locations")
    if (message.includes("hierarchy") || message.includes("parent") || message.includes("child")) {
      entities.features.push("location hierarchy")
    }
    if (message.includes("stock") && (message.includes("view") || message.includes("see") || message.includes("check"))) {
      entities.features.push("viewing stock by location")
    }
    
    return {
      intents,
      entities
    }
  }
  
  // Handle follow-up queries based on conversation context
  handleContextualQuery(message, analysis) {
    // Get the last agent message to check its context
    const agentMessages = this.conversationHistory.filter(msg => msg.type === 'agent')
    if (agentMessages.length === 0) return null
    
    const lastAgentMessage = agentMessages[agentMessages.length - 1]
    const context = lastAgentMessage.context || this.currentContext
    
    if (!context) return null
    
    // Check for affirmative/negative responses
    const isAffirmative = /\b(yes|yeah|yep|sure|okay|ok|please|definitely|absolutely)\b/i.test(message)
    const isNegative = /\b(no|nope|not|don't|won't|never|negative)\b/i.test(message)
    
    // Handle contextual responses based on the current context
    switch (context) {
      case "inventory":
        // Check for specific inventory management features
        for (const [feature, text] of Object.entries(this.responses["inventory management"].followUp)) {
          if (analysis.entities.features.includes(feature) || message.includes(feature.toLowerCase())) {
            return {
              message: text,
              context: "inventory",
              confidenceScore: 0.9,
              quickReplies: ["Yes, please", "No, thanks", "Tell me about a different feature"]
            }
          }
        }
        
        // Handle generic inventory follow-up
        if (isAffirmative) {
          return {
            message: "Great! Our inventory management system allows you to track stock levels across all locations, set up low stock alerts, perform transfers, and generate reports. Which specific feature would you like to learn more about?",
            context: "inventory",
            confidenceScore: 0.8,
            quickReplies: this.responses["inventory management"].features
          }
        }
        break;
        
      case "products":
        // Check for specific product management features
        for (const [feature, text] of Object.entries(this.responses["product management"].followUp)) {
          if (analysis.entities.features.includes(feature) || message.includes(feature.toLowerCase())) {
            return {
              message: text,
              context: "products",
              confidenceScore: 0.9,
              quickReplies: ["Yes, please", "No, thanks", "Tell me about a different feature"]
            }
          }
        }
        
        // Handle generic product follow-up
        if (isAffirmative) {
          return {
            message: "Perfect! Our product management system allows you to organize your products by category, set pricing with automatic margin calculation, track dimensions, and configure reorder points. What aspect would you like to explore?",
            context: "products",
            confidenceScore: 0.8,
            quickReplies: this.responses["product management"].features
          }
        }
        break;
        
      case "locations":
        // Check for specific location management features
        for (const [feature, text] of Object.entries(this.responses["location management"].followUp)) {
          if (analysis.entities.features.includes(feature) || message.includes(feature.toLowerCase())) {
            return {
              message: text,
              context: "locations",
              confidenceScore: 0.9,
              quickReplies: ["Yes, please", "No, thanks", "Tell me about a different feature"]
            }
          }
        }
        
        // Handle generic location follow-up
        if (isAffirmative) {
          return {
            message: "Excellent! Our location management features allow you to create and manage multiple warehouses or stores, establish parent-child relationships, and view stock levels at each location. What would you like to know more about?",
            context: "locations",
            confidenceScore: 0.8,
            quickReplies: this.responses["location management"].features
          }
        }
        break;
        
      case "billing":
        // Check for specific billing features
        for (const [feature, text] of Object.entries(this.responses["billing question"].followUp)) {
          if (message.includes(feature.toLowerCase())) {
            return {
              message: text,
              context: "billing",
              confidenceScore: 0.9,
              quickReplies: ["Yes, please", "No, thanks", "Tell me about a different feature"]
            }
          }
        }
        break;
        
      case "support":
        // Check for specific support features
        for (const [feature, text] of Object.entries(this.responses["technical support"].followUp)) {
          if (message.includes(feature.toLowerCase())) {
            return {
              message: text,
              context: "support",
              confidenceScore: 0.9,
              quickReplies: ["Yes, that's right", "No, that's not it", "I need different help"]
            }
          }
        }
        break;
    }
    
    // If no specific contextual response matched, return null to fall back to general handler
    return null
  }

  scrollToBottom(element) {
    if (element) {
      element.scrollTop = element.scrollHeight
    }
  }

  escapeHTML(html) {
    const div = document.createElement('div')
    div.textContent = html
    return div.innerHTML
  }
}
