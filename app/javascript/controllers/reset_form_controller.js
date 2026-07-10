import { Controller } from "@hotwired/stimulus"

// Resets the form after a successful Turbo Stream submission (e.g. episode chat).
export default class extends Controller {
  reset(event) {
    if (event.detail?.success !== false) this.element.reset()
  }
}
