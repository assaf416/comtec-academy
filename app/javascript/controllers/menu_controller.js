import { Controller } from "@hotwired/stimulus"

// Framework-agnostic kebab menu: toggles .is-open on the menu, closes on
// outside click or Escape.
export default class extends Controller {
  static targets = ["menu"]

  connect() {
    this.onDocClick = (e) => { if (!this.element.contains(e.target)) this.close() }
    this.onKey = (e) => { if (e.key === "Escape") this.close() }
    document.addEventListener("click", this.onDocClick)
    document.addEventListener("keydown", this.onKey)
  }

  disconnect() {
    document.removeEventListener("click", this.onDocClick)
    document.removeEventListener("keydown", this.onKey)
  }

  toggle(event) {
    event.stopPropagation()
    this.menuTarget.classList.toggle("is-open")
  }

  close() {
    this.menuTarget.classList.remove("is-open")
  }
}
