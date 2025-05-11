import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sample-avatar"
export default class extends Controller {
  selectAvatar(event) {
    // Find the clicked avatar option
    const avatarOption = event.target.closest('.avatar-option')
    if (!avatarOption) return
    
    // Get the URL from the data attribute
    const url = avatarOption.dataset.url
    
    // Find the avatar input field and update its value
    const avatarInput = document.querySelector('input[name="user[avatar]"]')
    if (avatarInput) {
      avatarInput.value = url
      
      // Trigger the input event to update the preview
      avatarInput.dispatchEvent(new Event('input'))
      
      // Add visual feedback
      document.querySelectorAll('.avatar-option div').forEach(div => {
        div.classList.remove('border-indigo-500', 'dark:border-indigo-400')
        div.classList.add('border-gray-200', 'dark:border-gray-700')
      })
      
      avatarOption.querySelector('div').classList.remove('border-gray-200', 'dark:border-gray-700')
      avatarOption.querySelector('div').classList.add('border-indigo-500', 'dark:border-indigo-400')
    }
  }
}
