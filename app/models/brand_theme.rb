class BrandTheme < ApplicationRecord
  has_one_attached :logo

  DEFAULTS = {
    primary_color: "#1f3a93",
    accent_color: "#e67e22",
    text_color: "#222222",
    background_color: "#ffffff",
    heading_font: "Heebo",
    body_font: "Assistant"
  }.freeze

  # Single global company theme; created with defaults on first access.
  def self.instance
    first || create!(DEFAULTS)
  end

  DEFAULTS.each_key do |attr|
    define_method(attr) { self[attr].presence || DEFAULTS[attr] }
  end

  # Google Fonts family list for the <link> tag.
  def font_families
    [heading_font, body_font].uniq.reject(&:blank?)
  end
end
