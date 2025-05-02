import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggle", "sunIcon", "moonIcon", "mobileToggle", "mobileSunIcon", "mobileMoonIcon"]

  connect() {
    // Initialize theme based on saved preference or system preference
    this.initializeTheme()

    // Listen for system preference changes
    this.setupSystemPreferenceListener()

    // Add theme transition class to enable smooth transitions
    document.documentElement.classList.add('theme-transition')
  }

  initializeTheme() {
    const savedTheme = localStorage.getItem('theme')

    if (savedTheme) {
      // Use saved preference if available
      this.applyTheme(savedTheme)
    } else {
      // Check system preference
      const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches
      const initialTheme = prefersDark ? 'dark' : 'light'
      this.applyTheme(initialTheme)
    }
  }

  setupSystemPreferenceListener() {
    // Only apply system preference changes if user hasn't set a preference
    window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', event => {
      if (!localStorage.getItem('theme')) {
        const newTheme = event.matches ? 'dark' : 'light'
        this.applyTheme(newTheme)
      }
    })
  }

  toggle(event) {
    // Prevent default behavior if it's a link
    if (event && event.preventDefault) event.preventDefault()

    // Get current theme and toggle it
    const currentTheme = document.documentElement.classList.contains('dark') ? 'dark' : 'light'
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark'

    // Apply the new theme with animation
    this.animateThemeChange(newTheme)
  }

  applyTheme(theme) {
    // Update the DOM
    if (theme === 'dark') {
      document.documentElement.classList.add('dark')

      // Update desktop toggle
      if (this.hasSunIconTarget) this.sunIconTarget.classList.add('hidden')
      if (this.hasMoonIconTarget) this.moonIconTarget.classList.remove('hidden')

      // Update mobile toggle if it exists
      if (this.hasMobileSunIconTarget) this.mobileSunIconTarget.classList.add('hidden')
      if (this.hasMobileMoonIconTarget) this.mobileMoonIconTarget.classList.remove('hidden')
    } else {
      document.documentElement.classList.remove('dark')

      // Update desktop toggle
      if (this.hasSunIconTarget) this.sunIconTarget.classList.remove('hidden')
      if (this.hasMoonIconTarget) this.moonIconTarget.classList.add('hidden')

      // Update mobile toggle if it exists
      if (this.hasMobileSunIconTarget) this.mobileSunIconTarget.classList.remove('hidden')
      if (this.hasMobileMoonIconTarget) this.mobileMoonIconTarget.classList.add('hidden')
    }

    // Save the preference
    localStorage.setItem('theme', theme)

    // Dispatch custom event for other components that might need to react to theme changes
    document.dispatchEvent(new CustomEvent('themeChanged', { detail: { theme } }))
  }

  animateThemeChange(newTheme) {
    // Create a ripple effect from the toggle button
    const ripple = document.createElement('div')
    ripple.className = `theme-ripple theme-ripple-${newTheme}`
    document.body.appendChild(ripple)

    // Trigger animation
    setTimeout(() => {
      ripple.classList.add('animate')

      // Apply theme after a short delay for visual effect
      setTimeout(() => {
        this.applyTheme(newTheme)

        // Remove ripple after animation completes
        setTimeout(() => {
          if (document.body.contains(ripple)) {
            document.body.removeChild(ripple)
          }
        }, 1000)
      }, 200)
    }, 10)
  }

  // Method to use system preference
  useSystemPreference(event) {
    if (event && event.preventDefault) event.preventDefault()

    // Remove saved preference
    localStorage.removeItem('theme')

    // Apply system preference
    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches
    const newTheme = prefersDark ? 'dark' : 'light'

    this.applyTheme(newTheme)
  }
}
