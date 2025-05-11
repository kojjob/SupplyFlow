import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static targets = ["list", "unreadCountBadge", "unreadCountHeader"]
  static values = {
    url: String, // For fetching notifications (index)
    markAsReadUrl: String, // For marking one as read (e.g., /notifications/:id/mark_as_read)
    markAllAsReadUrl: String // For marking all as read
  }

  connect() {
    this.subscription = consumer.subscriptions.create("NotificationChannel", {
      connected: this._connected.bind(this),
      disconnected: this._disconnected.bind(this),
      received: this._received.bind(this)
    })
    this.updateUnreadCountBadge(this.initialUnreadCount)
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
  }

  _connected() {
    console.log("NotificationsController connected to NotificationChannel")
  }

  _disconnected() {
    console.log("NotificationsController disconnected from NotificationChannel")
  }

  _received(data) {
    console.log("NotificationsController received data:", data)
    // Prepend to list and update count
    this.prependNotification(data)
    this.incrementUnreadCount()

    // Also dispatch the toast event, as the main channel subscription might not be active on all pages
    // or if this controller initializes after the main channel.
    const event = new CustomEvent("toast:show", {
      detail: {
        type: data.read ? 'info' : 'success',
        message: data.message || "New notification",
        title: data.actor_name ? `${data.actor_name} says:` : "Notification",
        duration: 7000
      }
    });
    window.dispatchEvent(event);
  }

  get initialUnreadCount() {
    // Try to get initial count from the badge in the navbar if it exists
    const badge = document.getElementById('navbar-unread-count');
    return badge ? parseInt(badge.textContent) || 0 : 0;
  }

  load() {
    if (this.listTarget.dataset.loaded === "true") return; // Don't load if already loaded

    fetch(this.urlValue, {
      headers: { "Accept": "application/json" }
    })
    .then(response => response.json())
    .then(data => {
      this.listTarget.innerHTML = "" // Clear current list (which might be from SSR)
      data.notifications.forEach(notification => {
        this.appendNotificationToList(notification)
      })
      this.updateUnreadCount(data.unread_count)
      this.listTarget.dataset.loaded = "true"
    })
    .catch(error => console.error("Error loading notifications:", error))
  }

  markAsRead(event) {
    event.preventDefault()
    const notificationElement = event.currentTarget
    const notificationId = notificationElement.dataset.notificationId
    if (!notificationId || notificationElement.dataset.read === "true") return

    const url = this.markAsReadUrlValue.replace(":id", notificationId)

    fetch(url, {
      method: "POST",
      headers: {
        "Accept": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        notificationElement.classList.remove("font-semibold", "bg-blue-50", "dark:bg-blue-900/5")
        notificationElement.dataset.read = "true"
        // Change icon background or unread dot
        const unreadDot = notificationElement.querySelector('.ml-2.flex-shrink-0 span.bg-blue-500');
        if (unreadDot) unreadDot.parentElement.remove(); // Remove the dot container
        const iconBg = notificationElement.querySelector('.w-10.h-10.rounded-full');
        if (iconBg) iconBg.classList.replace('bg-blue-500', 'bg-gray-500');


        this.updateUnreadCount(data.unread_count)
      }
    })
    .catch(error => console.error("Error marking notification as read:", error))
  }

  markAllAsRead() {
    fetch(this.markAllAsReadUrlValue, {
      method: "POST",
      headers: {
        "Accept": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        this.listTarget.querySelectorAll("a[data-notification-id]").forEach(el => {
          el.classList.remove("font-semibold", "bg-blue-50", "dark:bg-blue-900/5")
          el.dataset.read = "true"
          const unreadDot = el.querySelector('.ml-2.flex-shrink-0 span.bg-blue-500');
          if (unreadDot) unreadDot.parentElement.remove();
          const iconBg = el.querySelector('.w-10.h-10.rounded-full');
          if (iconBg) iconBg.classList.replace('bg-blue-500', 'bg-gray-500');
        })
        this.updateUnreadCount(0)
      }
    })
    .catch(error => console.error("Error marking all notifications as read:", error))
  }

  prependNotification(notification) {
    const notificationHTML = this.createNotificationHTML(notification)
    this.listTarget.insertAdjacentHTML("afterbegin", notificationHTML)
    // Remove "No new notifications" message if present
    const noNotificationsMessage = this.listTarget.querySelector('p.text-center');
    if (noNotificationsMessage) noNotificationsMessage.remove();
  }
  
  appendNotificationToList(notification) {
    const notificationHTML = this.createNotificationHTML(notification)
    this.listTarget.insertAdjacentHTML("beforeend", notificationHTML)
  }

  createNotificationHTML(notification) {
    const readClasses = notification.read ? '' : 'font-semibold bg-blue-50 dark:bg-blue-900/5'
    const iconBgColor = notification.read ? 'bg-gray-500' : 'bg-blue-500'
    const unreadDotHTML = notification.read ? '' : `
      <div class="ml-2 flex-shrink-0 self-center">
        <span class="w-2 h-2 bg-blue-500 rounded-full block"></span>
      </div>
    `
    // Use a placeholder icon, or make it dynamic based on notification.action
    const iconClass = "fas fa-info-circle text-lg"; 

    return `
      <a href="${notification.link || '#'}" class="block p-4 border-b border-gray-100 dark:border-gray-700 hover:bg-blue-50 dark:hover:bg-blue-900/10 transition-colors duration-200 ${readClasses}" data-action="click->notifications#markAsRead" data-notification-id="${notification.id}" data-read="${notification.read}">
        <div class="flex">
          <div class="flex-shrink-0 mr-3">
            <div class="w-10 h-10 rounded-full ${iconBgColor} flex items-center justify-center text-white shadow-md">
              <i class="${iconClass}"></i>
            </div>
          </div>
          <div class="flex-1">
            <p class="text-sm text-gray-800 dark:text-gray-200">${notification.message}</p>
            <p class="text-xs text-gray-500 dark:text-gray-400 mt-1">${this.timeAgo(notification.created_at)} ago</p>
          </div>
          ${unreadDotHTML}
        </div>
      </a>
    `
  }

  updateUnreadCount(count) {
    if (this.hasUnreadCountBadgeTarget) {
      this.unreadCountBadgeTarget.textContent = count
      this.unreadCountBadgeTarget.classList.toggle("hidden", count === 0)
    }
    if (this.hasUnreadCountHeaderTarget) {
      this.unreadCountHeaderTarget.textContent = `${count} new`
    }
    // Update the main navbar badge as well
    const mainBadge = document.getElementById('navbar-unread-count');
    if (mainBadge) {
        mainBadge.textContent = count;
        mainBadge.classList.toggle('hidden', count === 0);
    }
  }
  
  incrementUnreadCount() {
    const currentCount = parseInt(this.unreadCountBadgeTarget.textContent || "0")
    this.updateUnreadCount(currentCount + 1)
  }

  // Simple time_ago_in_words replacement (consider a library for i18n and more precision)
  timeAgo(timestamp) {
    const now = new Date();
    const seconds = Math.round((now - new Date(timestamp)) / 1000);

    if (seconds < 60) return `${seconds} seconds`;
    const minutes = Math.round(seconds / 60);
    if (minutes < 60) return `${minutes} minutes`;
    const hours = Math.round(minutes / 60);
    if (hours < 24) return `${hours} hours`;
    const days = Math.round(hours / 24);
    return `${days} days`;
  }
}
