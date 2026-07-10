# Font Awesome icons. `icon(:key)` renders a `<i class="fa-solid fa-…">` for a
# model/section/action key (see FA), used in the sidebar, page titles and headers.
module IconHelper
  FA = {
    # models / areas
    courses: "graduation-cap", course: "graduation-cap",
    library: "book",
    presentations: "display", presentation: "display",
    document: "file-lines", documents: "file-lines",
    episode: "circle-play", episodes: "circle-play",
    quiz: "circle-question",
    projects: "diagram-project", project: "diagram-project",
    layouts: "table-columns", layout: "table-columns",
    users: "users", user: "user",
    activity: "chart-line",
    branding: "palette",
    upload: "file-arrow-up",
    slide: "image", chat: "comments", favorite: "heart",
    # sections / actions
    dashboard: "gauge-high", build: "clapperboard", settings: "gear",
    signin: "right-to-bracket", signout: "right-from-bracket",
    edit: "pen-to-square", delete: "trash", resend: "paper-plane",
    view: "eye", open: "up-right-from-square", studio: "clapperboard",
    add: "plus", menu: "ellipsis-vertical",
    hash: "hashtag"
  }.freeze

  def icon(key, style: "solid")
    name = FA.fetch(key.to_sym, key.to_s)
    tag.i(nil, class: "icon fa-#{style} fa-#{name}", aria: { hidden: true })
  end
end
