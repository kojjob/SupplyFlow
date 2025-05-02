import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dropdown"]

  connect() {
    // Initialize the controller
    this.isOpen = false

    // Close dropdown when clicking outside
    document.addEventListener('click', this.handleClickOutside.bind(this))
  }

  disconnect() {
    document.removeEventListener('click', this.handleClickOutside.bind(this))
  }

  toggle(event) {
    event.stopPropagation()
    if (this.isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.dropdownTarget.classList.remove("scale-0", "opacity-0")
    this.dropdownTarget.classList.add("scale-100", "opacity-100")
    this.dropdownTarget.style.transform = "scale(1)"
    this.isOpen = true
  }

  close() {
    this.dropdownTarget.classList.add("scale-0", "opacity-0")
    this.dropdownTarget.classList.remove("scale-100", "opacity-100")
    this.dropdownTarget.style.transform = "scale(0)"
    this.isOpen = false
  }

  handleClickOutside(event) {
    if (this.isOpen && !this.element.contains(event.target)) {
      this.close()
    }
  }
}
