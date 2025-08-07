export default class extends Controller {
  static targets = ["input", "output", "placeholder"]
  
  connect() {
    // Check if there's already an image displayed
    if (this.hasOutputTarget && this.outputTarget.src && this.outputTarget.src !== '') {
      this.outputTarget.classList.remove('hidden')
      if (this.hasPlaceholderTarget) {
        this.placeholderTarget.classList.add('hidden')
      }
    }
  }
  
  preview() {
    const file = this.inputTarget.files[0]
    if (file) {
      // Show image preview
      if (this.hasOutputTarget) {
        const reader = new FileReader()
        reader.onload = (e) => {
          this.outputTarget.src = e.target.result
          this.outputTarget.classList.remove('hidden')
        }
        reader.readAsDataURL(file)
      }
      
      // Hide placeholder
      if (this.hasPlaceholderTarget) {
        this.placeholderTarget.classList.add('hidden')
      }
    } else {
      // Reset to placeholder if no file selected
      if (this.hasOutputTarget) {
        this.outputTarget.classList.add('hidden')
      }
      
      if (this.hasPlaceholderTarget) {
        this.placeholderTarget.classList.remove('hidden')
      }
    }
  }
}