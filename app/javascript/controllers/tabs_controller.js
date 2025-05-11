import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['tab', 'panel']
  static values = {
    activeTabClass: String,
    defaultTab: { type: Number, default: 0 }
  }
  
  connect() {
    // Set default active tab on connect
    this.selectTabByIndex(this.defaultTabValue)
  }
  
  selectTab(event) {
    event.preventDefault()
    
    // Find the index of the clicked tab
    const clickedTab = event.currentTarget
    const tabIndex = this.tabTargets.indexOf(clickedTab)
    
    // Select the tab at this index
    this.selectTabByIndex(tabIndex)
  }
  
  selectTabByIndex(index) {
    // Make sure the index is valid
    if (index < 0 || index >= this.tabTargets.length) {
      index = 0
    }
    
    // Update tab styling
    this.tabTargets.forEach((tab, i) => {
      // Add or remove active class
      if (i === index) {
        tab.classList.add('active')
        if (this.hasActiveTabClassValue) {
          tab.classList.add(this.activeTabClassValue)
        }
      } else {
        tab.classList.remove('active')
        if (this.hasActiveTabClassValue) {
          tab.classList.remove(this.activeTabClassValue)
        }
      }
    })
    
    // Show the selected panel and hide others
    this.panelTargets.forEach((panel, i) => {
      if (i === index) {
        panel.classList.remove('hidden')
      } else {
        panel.classList.add('hidden')
      }
    })
    
    // Dispatch event for other controllers to react
    this.dispatch('tabChanged', { detail: { index, tab: this.tabTargets[index], panel: this.panelTargets[index] } })
  }
}