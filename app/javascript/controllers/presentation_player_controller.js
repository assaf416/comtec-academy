import { Controller } from "@hotwired/stimulus"

// Sequentially plays a presentation: shows each slide, plays its voice-over (or
// waits its duration for silent slides), advances, and moves the timeline highlight.
export default class extends Controller {
  static targets = ["slide", "audio", "caption"]

  connect() {
    this.index = 0
    this.timer = null
  }

  play() {
    this.clearTimer()
    this.show(this.index)
  }

  show(i) {
    if (i >= this.slideTargets.length) { this.stop(); return }
    this.index = i
    this.slideTargets.forEach((el, j) => el.classList.toggle("is-active", j === i))
    this.highlight(i)

    const slide = this.slideTargets[i]
    if (this.hasCaptionTarget) this.captionTarget.textContent = slide.dataset.caption || ""

    const url = slide.dataset.audio
    if (url) {
      this.audioTarget.src = url
      this.audioTarget.play().catch(() => this.scheduleNext(slide))
    } else {
      this.scheduleNext(slide)
    }
  }

  scheduleNext(slide) {
    const ms = (parseFloat(slide.dataset.duration) || 4) * 1000
    this.timer = setTimeout(() => this.next(), ms)
  }

  next() { this.show(this.index + 1) }

  stop() {
    this.clearTimer()
    this.audioTarget.pause()
    this.audioTarget.currentTime = 0
    this.index = 0
    this.slideTargets.forEach((el, j) => el.classList.toggle("is-active", j === 0))
    this.highlight(-1)
    if (this.hasCaptionTarget) this.captionTarget.textContent = ""
  }

  highlight(i) {
    this.element.querySelectorAll(".daw-clip").forEach((clip) => {
      const idx = clip.dataset.slideIndex
      clip.classList.toggle("is-playing", idx !== undefined && Number(idx) === i)
    })
  }

  clearTimer() {
    if (this.timer) { clearTimeout(this.timer); this.timer = null }
  }

  disconnect() { this.clearTimer() }
}
