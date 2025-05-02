import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["loader"]

  connect() {
    document.addEventListener('turbo:before-visit', this.showLoader.bind(this))
    document.addEventListener('turbo:load', this.hideLoader.bind(this))
    document.addEventListener('turbo:before-fetch-response', this.checkResponse.bind(this))
  }
  
  disconnect() {
    document.removeEventListener('turbo:before-visit', this.showLoader.bind(this))
    document.removeEventListener('turbo:load', this.hideLoader.bind(this))
    document.removeEventListener('turbo:before-fetch-response', this.checkResponse.bind(this))
  }
  
  showLoader() {
    this.loaderTarget.classList.remove('opacity-0')
    this.loaderTarget.classList.remove('invisible')
  }
  
  hideLoader() {
    this.loaderTarget.classList.add('opacity-0')
    setTimeout(() => {
      this.loaderTarget.classList.add('invisible')
    }, 500)
  }
  
  checkResponse(event) {
    // If the response is an error, we still want to hide the loader
    if (!event.detail.fetchResponse.succeeded) {
      this.hideLoader()
    }
  }
}
