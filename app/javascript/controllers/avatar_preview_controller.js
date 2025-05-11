import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="avatar-preview"
export default class extends Controller {
  connect() {
    // Initialize if needed
  }

  // Update preview from file input
  updateFromFile(event) {
    const fileInput = event.target
    const file = fileInput.files[0]

    if (file) {
      // Clear the URL input
      const urlInput = document.querySelector('input[name="user[avatar_url]"]')
      if (urlInput) urlInput.value = ''

      // Update the preview
      const reader = new FileReader()
      reader.onload = (e) => {
        this.updatePreviewImage(e.target.result)
      }
      reader.readAsDataURL(file)
    }
  }

  // Update preview from URL input
  updateFromUrl(event) {
    const urlInput = event.target
    const url = urlInput.value.trim()

    if (url) {
      // Clear the file input
      const fileInput = document.querySelector('input[name="user[avatar]"]')
      if (fileInput) fileInput.value = ''

      // Update the preview
      this.updatePreviewImage(url)
    } else {
      // Show initial if URL is empty
      this.showInitial()
    }
  }

  // Select a sample avatar
  selectSampleAvatar(event) {
    // Find the clicked avatar option
    const avatarOption = event.target.closest('.avatar-option')
    if (!avatarOption) return

    // Get the URL from the data attribute
    const url = avatarOption.dataset.url

    // Update the URL input
    const urlInput = document.querySelector('input[name="user[avatar_url]"]')
    if (urlInput) {
      urlInput.value = url

      // Clear the file input
      const fileInput = document.querySelector('input[name="user[avatar]"]')
      if (fileInput) fileInput.value = ''

      // Update the preview
      this.updatePreviewImage(url)

      // Add visual feedback
      document.querySelectorAll('.avatar-option div').forEach(div => {
        div.classList.remove('border-indigo-500', 'dark:border-indigo-400')
        div.classList.add('border-gray-200', 'dark:border-gray-700')
      })

      avatarOption.querySelector('div').classList.remove('border-gray-200', 'dark:border-gray-700')
      avatarOption.querySelector('div').classList.add('border-indigo-500', 'dark:border-indigo-400')
    }
  }

  // Helper to update the preview image
  updatePreviewImage(src) {
    const previewImg = document.getElementById('avatar-preview-img')
    const initialSpan = document.getElementById('avatar-initial')

    if (previewImg) {
      // Update existing image
      previewImg.src = src
      previewImg.style.display = 'block'
      if (initialSpan) initialSpan.style.display = 'none'
    } else {
      // Create new image
      const previewContainer = document.querySelector('.w-20.h-20.rounded-full')
      if (previewContainer) {
        // Clear container
        previewContainer.innerHTML = ''

        // Add image
        const img = document.createElement('img')
        img.src = src
        img.id = 'avatar-preview-img'
        img.className = 'w-full h-full object-cover'
        img.onerror = () => this.showInitial()

        previewContainer.appendChild(img)
      }
    }
  }

  // Helper to show the initial
  showInitial() {
    const previewImg = document.getElementById('avatar-preview-img')
    const initialSpan = document.getElementById('avatar-initial')
    const nameInput = document.querySelector('input[name="user[name]"]')

    if (previewImg) previewImg.style.display = 'none'

    if (initialSpan) {
      initialSpan.style.display = 'block'
      initialSpan.textContent = nameInput ? nameInput.value.charAt(0).toUpperCase() : 'U'
    } else {
      // Create new initial span
      const previewContainer = document.querySelector('.w-20.h-20.rounded-full')
      if (previewContainer) {
        // Clear container
        previewContainer.innerHTML = ''

        // Add initial
        const span = document.createElement('span')
        span.id = 'avatar-initial'
        span.className = 'text-4xl'
        span.textContent = nameInput ? nameInput.value.charAt(0).toUpperCase() : 'U'

        previewContainer.appendChild(span)
      }
    }
  }
}
