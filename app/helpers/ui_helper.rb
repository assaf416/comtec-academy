# Maps semantic UI components to framework-specific CSS classes so a single set
# of views can render under either Bootstrap (web) or Bulma (mobile). Views call
# `ui_class(:button, :primary)`; this returns the right classes for whichever
# framework `css_framework` (set in ApplicationController) resolved to.
module UiHelper
  UI = {
    bootstrap: {
      button:     { _base: "btn",            primary: "btn-primary", secondary: "btn-outline-secondary", danger: "btn-danger", link: "btn-link", small: "btn-sm", block: "w-100" },
      container:  { _base: "container py-4" },
      card:       { _base: "card h-100 shadow-sm" },
      card_body:  { _base: "card-body" },
      card_title: { _base: "card-title h5" },
      input:      { _base: "form-control" },
      select:     { _base: "form-select" },
      textarea:   { _base: "form-control" },
      label:      { _base: "form-label" },
      field:      { _base: "mb-3" },
      title:      { _base: "h3 mb-4" },
      subtitle:   { _base: "h5 text-muted mb-3" },
      table:      { _base: "table table-striped align-middle" },
      badge:      { _base: "badge",          info: "text-bg-info", success: "text-bg-success", warning: "text-bg-warning", muted: "text-bg-secondary" },
      alert:      { _base: "alert",          notice: "alert-success", alert: "alert-danger" },
      grid:       { _base: "row g-3" },
      grid_item:  { _base: "col-12 col-sm-6 col-lg-4" }
    },
    bulma: {
      button:     { _base: "button",         primary: "is-primary", secondary: "is-light", danger: "is-danger", link: "is-text", small: "is-small", block: "is-fullwidth" },
      container:  { _base: "container p-4" },
      card:       { _base: "card" },
      card_body:  { _base: "card-content" },
      card_title: { _base: "title is-5" },
      input:      { _base: "input" },
      select:     { _base: "select is-fullwidth" },
      textarea:   { _base: "textarea" },
      label:      { _base: "label" },
      field:      { _base: "field" },
      title:      { _base: "title is-4" },
      subtitle:   { _base: "subtitle is-6" },
      table:      { _base: "table is-striped is-fullwidth" },
      badge:      { _base: "tag",            info: "is-info", success: "is-success", warning: "is-warning", muted: "is-light" },
      alert:      { _base: "notification",   notice: "is-success", alert: "is-danger" },
      grid:       { _base: "columns is-multiline" },
      grid_item:  { _base: "column is-one-third" }
    }
  }.freeze

  def ui_class(component, *variants)
    map = UI.fetch(css_framework, {}).fetch(component, {})
    [ map[:_base], *variants.map { |v| map[v.to_sym] } ].compact.join(" ")
  end

  def flash_class(level)
    ui_class(:alert, level.to_sym == :notice ? :notice : :alert)
  end
end
