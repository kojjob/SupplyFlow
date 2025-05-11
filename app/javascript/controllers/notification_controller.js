import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["filterTab", "notificationItem", "loadMoreButton"]
  
  connect() {
    this.initializeFilters()
    this.initializeRealTimeUpdates()
  }
  
  initializeFilters() {
    // Add event listeners to filter tabs
    const filterTabs = document.querySelectorAll('.filter-tab')
    filterTabs.forEach(tab => {
      tab.addEventListener('click', (e) => this.filterNotifications(e))
    })
  }
  
  filterNotifications(event) {
    const filterType = event.currentTarget.dataset.filter
    const allTabs = document.querySelectorAll('.filter-tab')
    const allNotifications = document.querySelectorAll('.notification-item')
    
    // Update active tab
    allTabs.forEach(tab => tab.classList.remove('active'))
    event.currentTarget.classList.add('active')
    
    // Filter notifications
    allNotifications.forEach(notification => {
      if (filterType === 'all') {
        notification.style.display = 'block'
      } else if (filterType === 'unread') {
        notification.style.display = notification.classList.contains('unread') ? 'block' : 'none'
      } else {
        notification.style.display = notification.dataset.type === filterType ? 'block' : 'none'
      }
    })
    
    // Animate visible notifications
    this.animateNotifications()
  }
  
  animateNotifications() {
    const visibleNotifications = document.querySelectorAll('.notification-item:not([style*="display: none"])')
    visibleNotifications.forEach((notification, index) => {
      notification.style.opacity = '0'
      notification.style.transform = 'translateY(20px)'
      
      setTimeout(() => {
        notification.style.transition = 'all 0.3s ease'
        notification.style.opacity = '1'
        notification.style.transform = 'translateY(0)'
      }, index * 50)
    })
  }
  
  markAsRead(event) {
    const notificationId = event.currentTarget.closest('.notification-item').dataset.notificationId
    const notificationElement = event.currentTarget.closest('.notification-item')
    
    // Visual feedback
    notificationElement.classList.remove('unread')
    event.currentTarget.remove()
    
    // Remove unread indicator
    const unreadIndicator = notificationElement.querySelector('.animate-ping').parentElement
    if (unreadIndicator) {
      unreadIndicator.remove()
    }
  }
  
  deleteNotification(event) {
    const notificationElement = event.currentTarget.closest('.notification-item')
    
    // Animate removal
    notificationElement.style.transition = 'all 0.3s ease'
    notificationElement.style.transform = 'translateX(100%)'
    notificationElement.style.opacity = '0'
    
    setTimeout(() => {
      notificationElement.remove()
      this.checkEmptyState()
    }, 300)
  }
  
  checkEmptyState() {
    const remainingNotifications = document.querySelectorAll('.notification-item')
    if (remainingNotifications.length === 0) {
      // Show empty state
      const emptyState = document.createElement('div')
      emptyState.innerHTML = `
        <div class="text-center py-16">
          <div class="inline-flex items-center justify-center w-24 h-24 rounded-full bg-gradient-to-r from-indigo-500 to-purple-500 mb-6">
            <i class="fas fa-bell-slash text-4xl text-white"></i>
          </div>
          <h3 class="text-2xl font-bold text-gray-900 dark:text-white mb-2">
            No Notifications
          </h3>
          <p class="text-gray-600 dark:text-gray-400 mb-8 max-w-md mx-auto">
            You're all caught up! We'll notify you when there's something new.
          </p>
        </div>
      `
      this.element.appendChild(emptyState)
    }
  }
  
  loadMore(event) {
    const button = event.currentTarget
    const spinner = button.querySelector('.fa-spinner')
    const arrow = button.querySelector('.fa-arrow-down')
    
    // Show loading state
    spinner.classList.remove('hidden')
    arrow.classList.add('hidden')
    button.disabled = true
    
    // Simulate loading more notifications (replace with actual AJAX call)
    setTimeout(() => {
      // Hide loading state
      spinner.classList.add('hidden')
      arrow.classList.remove('hidden')
      button.disabled = false
      
      // In a real implementation, append more notifications here
    }, 1000)
  }
  
  initializeRealTimeUpdates() {
    // Set up ActionCable subscription for real-time notifications
    if (typeof App !== 'undefined' && App.cable) {
      this.subscription = App.cable.subscriptions.create(
        { channel: "NotificationsChannel" },
        {
          received: (data) => {
            this.handleNewNotification(data)
          }
        }
      )
    }
  }
  
  handleNewNotification(data) {
    // Parse the notification HTML
    const parser = new DOMParser()
    const doc = parser.parseFromString(data.notification_html, 'text/html')
    const newNotification = doc.body.firstChild
    
    // Add animation classes
    newNotification.style.opacity = '0'
    newNotification.style.transform = 'translateY(-20px)'
    
    // Prepend to notifications list
    const notificationsList = this.element.querySelector('.space-y-4')
    notificationsList.insertBefore(newNotification, notificationsList.firstChild)
    
    // Animate in
    setTimeout(() => {
      newNotification.style.transition = 'all 0.5s ease'
      newNotification.style.opacity = '1'
      newNotification.style.transform = 'translateY(0)'
    }, 100)
    
    // Update unread count
    this.updateUnreadCount(data.unread_count)
    
    // Show desktop notification if permission granted
    if (Notification.permission === 'granted') {
      new Notification(data.title, {
        body: data.message,
        icon: '/assets/notification-icon.png'
      })
    }
  }
  
  updateUnreadCount(count) {
    const unreadCountElement = document.querySelector('[data-unread-count]')
    if (unreadCountElement) {
      unreadCountElement.textContent = count
      
      // Add pulse animation for new notifications
      unreadCountElement.classList.add('animate-pulse')
      setTimeout(() => {
        unreadCountElement.classList.remove('animate-pulse')
      }, 2000)
    }
  }
  
  requestNotificationPermission() {
    if ('Notification' in window && Notification.permission !== 'granted') {
      Notification.requestPermission()
    }
  }
  
  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
  }
}