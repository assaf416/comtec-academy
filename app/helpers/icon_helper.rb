# Small bundled inline-SVG icon set (line style, currentColor, 24x24 viewBox).
# No external dependency; RTL-safe. Use via `icon("courses")`.
module IconHelper
  ICONS = {
    "hash" => %(<line x1="4" y1="9" x2="20" y2="9"/><line x1="4" y1="15" x2="20" y2="15"/><line x1="10" y1="3" x2="8" y2="21"/><line x1="16" y1="3" x2="14" y2="21"/>),
    "courses" => %(<path d="M4 19V5a1 1 0 0 1 1-1h9v16H5a1 1 0 0 1-1-1z"/><path d="M14 4h5a1 1 0 0 1 1 1v13a1 1 0 0 1-1 1h-5"/>),
    "library" => %(<path d="M12 2 2 7l10 5 10-5z"/><path d="M2 12l10 5 10-5"/><path d="M2 17l10 5 10-5"/>),
    "presentations" => %(<rect x="3" y="4" width="18" height="12" rx="1"/><line x1="12" y1="16" x2="12" y2="20"/><line x1="8" y1="20" x2="16" y2="20"/><polygon points="10,8 15,10 10,12"/>),
    "dashboard" => %(<rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/>),
    "projects" => %(<path d="M3 7a2 2 0 0 1 2-2h4l2 2h8a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>),
    "build" => %(<rect x="3" y="4" width="18" height="16" rx="2"/><line x1="7" y1="4" x2="7" y2="20"/><line x1="17" y1="4" x2="17" y2="20"/><line x1="3" y1="9" x2="7" y2="9"/><line x1="3" y1="14" x2="7" y2="14"/><line x1="17" y1="9" x2="21" y2="9"/><line x1="17" y1="14" x2="21" y2="14"/>),
    "layouts" => %(<rect x="3" y="3" width="18" height="18" rx="2"/><line x1="3" y1="9" x2="21" y2="9"/><line x1="9" y1="21" x2="9" y2="9"/>),
    "users" => %(<path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/>),
    "activity" => %(<polyline points="22,12 18,12 15,21 9,3 6,12 2,12"/>),
    "settings" => %(<circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 8 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 8a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/>),
    "signin" => %(<path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4"/><polyline points="10,17 15,12 10,7"/><line x1="15" y1="12" x2="3" y2="12"/>)
  }.freeze

  def icon(name, size: 18)
    inner = ICONS.fetch(name.to_s, ICONS["hash"])
    attrs = %(class="icon" width="#{size.to_i}" height="#{size.to_i}" viewBox="0 0 24 24" ) +
            %(fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true")
    "<svg #{attrs}>#{inner}</svg>".html_safe
  end
end
