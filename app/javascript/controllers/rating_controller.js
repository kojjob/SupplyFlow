import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["star", "input"]
  
  connect() {
    this.updateStars(0)
    
    // If there's already a value in the input, reflect it in the stars
    if (this.hasInputTarget && this.inputTarget.value) {
      this.updateStars(parseInt(this.inputTarget.value))
    }
  }
  
  select(event) {
    const rating = parseInt(event.currentTarget.dataset.value)
    this.updateStars(rating)
    
    if (this.hasInputTarget) {
      this.inputTarget.value = rating
    }
  }
  
  updateStars(rating) {
    if (this.hasStarTarget) {
      this.starTargets.forEach((star, index) => {
        const starValue = index + 1
        
        if (starValue <= rating) {
          star.innerHTML = '<i class="fas fa-star"></i>'
          star.classList.add('text-yellow-400')
          star.classList.remove('text-gray-300', 'dark:text-gray-600')
        } else {
          star.innerHTML = '<i class="far fa-star"></i>'
          star.classList.remove('text-yellow-400')
          star.classList.add('text-gray-300', 'dark:text-gray-600')
        }
      })
    }
  }
}