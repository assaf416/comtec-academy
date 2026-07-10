module Presentations
  # Rebuilds a presentation's slides from its markdown screenplay, upserting by
  # position. Clears a slide's stale audio duration when its narration changed.
  module Builder
    module_function

    def sync!(presentation)
      parsed = ScreenplayParser.parse(presentation.source_md)
      parsed.each_with_index do |data, i|
        slide = presentation.slides.find_or_initialize_by(position: i + 1)
        slide.duration = nil if slide.notes != data[:notes]
        slide.content = data[:content]
        slide.notes = data[:notes]
        slide.choices = data[:choices] || []
        slide.correct_choice = data[:correct]
        slide.layout = resolve_layout(data)
        slide.save!
      end
      presentation.slides.where("position > ?", parsed.size).destroy_all
      presentation.slides.reload
    end

    # Named layout wins; otherwise pick by content (code fence / quiz block / plain).
    def resolve_layout(data)
      if data[:layout_key].present? && (named = Layout.for_key(data[:layout_key]))
        return named
      end

      Layout.default_for(has_code: data[:content].to_s.match?(/^```/),
                         has_quiz: data[:choices].present?)
    end
  end
end
