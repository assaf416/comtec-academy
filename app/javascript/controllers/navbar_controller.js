import { Controller } from "@hotwired/stimulus"

// Toggles the Bulma mobile navbar menu when the burger is tapped.
export default class extends Controller {
  static targets = ["burger", "menu"]

  toggle() {
    this.burgerTarget.classList.toggle("is-active")
    this.menuTarget.classList.toggle("is-active")
  }
}
