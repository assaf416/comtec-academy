import { Controller } from "@hotwired/stimulus"

// Toggles the off-canvas sidebar on mobile (added to .app-shell).
export default class extends Controller {
  toggle() {
    this.element.classList.toggle("is-open")
  }
}
