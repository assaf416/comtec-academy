import { Controller } from "@hotwired/stimulus"

// Simple tab switcher for the builder side panel (Audio / Screenplay).
export default class extends Controller {
  static targets = ["tab", "panel"]

  select(event) {
    const panel = event.currentTarget.dataset.panel
    this.tabTargets.forEach((t) => t.classList.toggle("is-active", t.dataset.panel === panel))
    this.panelTargets.forEach((p) => p.classList.toggle("is-active", p.dataset.panel === panel))
  }
}
