module NotificationsHelper
    def notification_icon(type)
      case type.to_s
      when 'low_stock'
        'fas fa-exclamation-triangle'
      when 'new_order'
        'fas fa-shopping-cart'
      when 'payment_received'
        'fas fa-money-check-alt'
      when 'order_shipped'
        'fas fa-truck'
      when 'order_delivered'
        'fas fa-check-circle'
      when 'order_canceled'
        'fas fa-times-circle'
      when 'purchase_order_received'
        'fas fa-box-open'
      when 'user_activity'
        'fas fa-user'
      when 'system'
        'fas fa-cog'
      when 'warning'
        'fas fa-exclamation-circle'
      when 'info'
        'fas fa-info-circle'
      when 'success'
        'fas fa-check'
      when 'error'
        'fas fa-exclamation'
      else
        'fas fa-bell'
      end
    end
  
    def notification_icon_color(type)
      case type.to_s
      when 'low_stock'
        'bg-gradient-to-r from-red-500 to-orange-500'
      when 'new_order'
        'bg-gradient-to-r from-blue-500 to-indigo-500'
      when 'payment_received'
        'bg-gradient-to-r from-green-500 to-emerald-500'
      when 'order_shipped'
        'bg-gradient-to-r from-purple-500 to-pink-500'
      when 'order_delivered'
        'bg-gradient-to-r from-teal-500 to-green-500'
      when 'order_canceled'
        'bg-gradient-to-r from-red-600 to-red-400'
      when 'purchase_order_received'
        'bg-gradient-to-r from-cyan-500 to-blue-500'
      when 'user_activity'
        'bg-gradient-to-r from-yellow-500 to-amber-500'
      when 'system'
        'bg-gradient-to-r from-gray-500 to-slate-500'
      when 'warning'
        'bg-gradient-to-r from-orange-500 to-yellow-500'
      when 'info'
        'bg-gradient-to-r from-blue-400 to-cyan-400'
      when 'success'
        'bg-gradient-to-r from-green-600 to-green-400'
      when 'error'
        'bg-gradient-to-r from-red-700 to-red-500'
      else
        'bg-gradient-to-r from-indigo-500 to-purple-500'
      end
    end
  
    def notification_priority_badge(priority)
      case priority.to_s.downcase
      when 'high'
        content_tag(:span, 'High', class: 'px-2 py-1 rounded-full text-xs font-semibold bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300')
      when 'medium'
        content_tag(:span, 'Medium', class: 'px-2 py-1 rounded-full text-xs font-semibold bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-300')
      when 'low'
        content_tag(:span, 'Low', class: 'px-2 py-1 rounded-full text-xs font-semibold bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300')
      else
        content_tag(:span, 'Normal', class: 'px-2 py-1 rounded-full text-xs font-semibold bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300')
      end
    end
  
    def notification_action_button(notification)
      return unless notification.url.present?
      
      case notification.action_type
      when 'view'
        link_to notification.url, class: 'btn-theme-primary text-sm' do
          content_tag(:i, '', class: 'fas fa-eye mr-2') + 'View Details'
        end
      when 'approve'
        link_to notification.url, method: :post, class: 'btn-theme-primary text-sm' do
          content_tag(:i, '', class: 'fas fa-check mr-2') + 'Approve'
        end
      when 'reject'
        link_to notification.url, method: :post, class: 'btn-danger text-sm' do
          content_tag(:i, '', class: 'fas fa-times mr-2') + 'Reject'
        end
      when 'download'
        link_to notification.url, class: 'btn-theme-secondary text-sm' do
          content_tag(:i, '', class: 'fas fa-download mr-2') + 'Download'
        end
      else
        link_to notification.url, class: 'btn-theme-ghost text-sm' do
          content_tag(:i, '', class: 'fas fa-arrow-right mr-2') + 'Go to'
        end
      end
    end
  
    def format_notification_time(time)
      if time > 1.day.ago
        "#{time_ago_in_words(time)} ago"
      elsif time > 1.week.ago
        time.strftime("%A at %I:%M %p")
      else
        time.strftime("%B %d at %I:%M %p")
      end
    end
  
    def notification_image(notification)
      case notification.notification_type
      when 'new_order'
        image_tag 'order-received.svg', class: 'w-16 h-16', alt: 'New Order'
      when 'low_stock'
        image_tag 'low-stock-warning.svg', class: 'w-16 h-16', alt: 'Low Stock'
      when 'payment_received'
        image_tag 'payment-success.svg', class: 'w-16 h-16', alt: 'Payment Received'
      else
        image_tag 'notification-bell.svg', class: 'w-16 h-16', alt: 'Notification'
      end
    end
  end