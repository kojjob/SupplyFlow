import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    // Initialize the controller
  }

  toggle() {
    this.menuTarget.classList.toggle("hidden")
  }
}
