import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="intake-events"
export default class extends Controller {
  static targets = ["container", "eventField", "template", "addButtonContainer"]
  
  connect() {
    this.maxEvents = 14
    this.updateAddButtonVisibility()
  }

  addEvent(event) {
    event.preventDefault()
    
    // Check if we've reached the max
    if (this.eventFieldTargets.length >= this.maxEvents) {
      alert(`You can add a maximum of ${this.maxEvents} events.`)
      return
    }

    // Get the template
    const template = this.templateTarget.content.cloneNode(true)
    const content = template.querySelector('.event-fields')
    
    if (!content) {
      console.error("Could not find event fields in template")
      return
    }

    // Replace NEW_RECORD with a unique timestamp
    const timestamp = new Date().getTime()
    const html = content.outerHTML.replace(/NEW_RECORD/g, timestamp)
    
    // Create a wrapper div and insert the HTML
    const wrapper = document.createElement('div')
    wrapper.innerHTML = html
    
    // Append to container
    this.containerTarget.appendChild(wrapper.firstElementChild)
    
    // Update button visibility
    this.updateAddButtonVisibility()
    
    // Focus on the date field of the new event
    const newField = this.eventFieldTargets[this.eventFieldTargets.length - 1]
    const dateInput = newField.querySelector('input[type="date"]')
    if (dateInput) {
      dateInput.focus()
    }
  }

  removeEvent(event) {
    event.preventDefault()
    
    const eventField = event.target.closest('[data-intake-events-target="eventField"]')
    if (!eventField) return
    
    // Check if this is a persisted record (has an ID)
    const idField = eventField.querySelector('input[name*="[id]"]')
    
    if (idField && idField.value) {
      // Mark for destruction but keep in DOM (hidden)
      const destroyField = eventField.querySelector('input[name*="[_destroy]"]')
      if (destroyField) {
        destroyField.value = '1'
      }
      eventField.style.display = 'none'
    } else {
      // Just remove from DOM if it's a new record
      eventField.remove()
    }
    
    // Ensure at least one event field remains
    const visibleFields = this.eventFieldTargets.filter(field => field.style.display !== 'none')
    if (visibleFields.length === 0) {
      this.addEvent(new Event('click'))
    }
    
    // Update button visibility
    this.updateAddButtonVisibility()
  }

  updateAddButtonVisibility() {
    const visibleFieldCount = this.eventFieldTargets.filter(
      field => field.style.display !== 'none'
    ).length
    
    if (this.hasAddButtonContainerTarget) {
      if (visibleFieldCount >= this.maxEvents) {
        this.addButtonContainerTarget.style.display = 'none'
      } else {
        this.addButtonContainerTarget.style.display = 'flex'
      }
    }
  }
}

