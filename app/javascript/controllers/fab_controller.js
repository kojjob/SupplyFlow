import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "button"]

  connect() {
    // Initialize the controller
    this.isOpen = false
  }

  toggle() {
    if (this.isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.menuTarget.classList.remove("scale-0", "opacity-0")
    this.menuTarget.classList.add("scale-100", "opacity-100")
    this.buttonTarget.classList.add("rotate-45")
    this.isOpen = true
  }

  close() {
    this.menuTarget.classList.add("scale-0", "opacity-0")
    this.menuTarget.classList.remove("scale-100", "opacity-100")
    this.buttonTarget.classList.remove("rotate-45")
    this.isOpen = false
  }
}
