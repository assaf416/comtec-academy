import { Controller } from "@hotwired/stimulus"

// End-user presentation viewer: step slide-by-slide, play the current slide's
// audio, and control its volume.
export default class extends Controller {
  static targets = ["slide", "audio", "position", "volume"]

  connect() {
    this.index = 0
    this.show(0)
  }

  show(i) {
    if (i < 0 || i >= this.slideTargets.length) return
    this.index = i
    this.slideTargets.forEach((el, j) => el.classList.toggle("is-active", j === i))
    const slide = this.slideTargets[i]
    this.audioTarget.pause()
    this.audioTarget.src = slide.dataset.audio || ""
    if (this.hasPositionTarget) this.positionTarget.textContent = `${i + 1} / ${this.slideTargets.length}`
  }

  next() { this.show(this.index + 1) }
  prev() { this.show(this.index - 1) }

  toggle() {
    if (this.audioTarget.paused) this.audioTarget.play().catch(() => {})
    else this.audioTarget.pause()
  }

  setVolume() {
    this.audioTarget.volume = parseFloat(this.volumeTarget.value)
  }
}
