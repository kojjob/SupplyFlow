import consumer from "channels/consumer"

consumer.subscriptions.create("NotificationChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
    console.log("Connected to NotificationChannel");
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
    console.log("Disconnected from NotificationChannel");
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    console.log("Received notification:", data);

    // Use the existing toast system to display the notification
    // The toast controller listens for 'toast:show' event on the window
    const event = new CustomEvent("toast:show", {
      detail: {
        type: data.read ? 'info' : 'success', // Or determine type based on data.type if available
        message: data.message || "New notification",
        title: data.actor_name ? `${data.actor_name} says:` : "Notification",
        duration: 7000 // Optional: duration in ms
      }
    });
    window.dispatchEvent(event);

    // You could also update a dedicated notification UI element here
    // For example, incrementing a badge counter or adding to a list:
    // const counter = document.getElementById('notification-counter');
    // if (counter) {
    //   counter.textContent = parseInt(counter.textContent || "0") + 1;
    //   counter.classList.remove('hidden');
    // }
  }
});
