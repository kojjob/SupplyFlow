import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="media-form"
export default class extends Controller {
  static targets = ["videoFields", "audioFields", "durationField"]

  connect() {
    this.updateFieldsVisibility()
  }

  updateType(event) {
    const selectedType = event.target.value
    this.updateFieldsVisibility(selectedType)
  }

  updateFieldsVisibility(mediaType) {
    // Get current media type if not provided
    if (!mediaType) {
      const selectedInput = this.element.querySelector('input[name="post[media_type]"]:checked')
      mediaType = selectedInput ? selectedInput.value : 'article'
    }

    // Hide all fields first
    this.hideAllFields()

    // Show relevant fields based on media type
    switch (mediaType) {
      case 'video':
        this.showVideoFields()
        this.showDurationField()
        break
      case 'audio':
      case 'podcast':
        this.showAudioFields()
        this.showDurationField()
        break
      case 'infographic':
      case 'gallery':
        this.showDurationField()
        break
      default:
        // Article type - no additional fields
        break
    }

    // Update radio button styling
    this.updateRadioStyling(mediaType)
  }

  hideAllFields() {
    this.videoFieldsTargets.forEach(field => field.classList.add('hidden'))
    this.audioFieldsTargets.forEach(field => field.classList.add('hidden'))
    this.durationFieldTargets.forEach(field => field.classList.add('hidden'))
  }

  showVideoFields() {
    this.videoFieldsTargets.forEach(field => field.classList.remove('hidden'))
  }

  showAudioFields() {
    this.audioFieldsTargets.forEach(field => field.classList.remove('hidden'))
  }

  showDurationField() {
    this.durationFieldTargets.forEach(field => field.classList.remove('hidden'))
  }

  updateRadioStyling(selectedType) {
    // Remove active styling from all labels
    const labels = this.element.querySelectorAll('label')
    labels.forEach(label => {
      label.classList.remove('bg-primary/10', 'border-primary')
      label.classList.add('border-gray-300', 'dark:border-gray-600')
    })

    // Add active styling to selected label
    const activeInput = this.element.querySelector(`input[value="${selectedType}"]`)
    if (activeInput) {
      const activeLabel = activeInput.closest('label')
      activeLabel.classList.add('bg-primary/10', 'border-primary')
      activeLabel.classList.remove('border-gray-300', 'dark:border-gray-600')
    }
  }
}