require "nokogiri"

module Docs
  # Imports every supported document in a folder into the Library as standalone
  # uploaded documents: markdown as-is, HTML converted (head/style/script stripped),
  # and office files via Docs::OfficeConverter. Idempotent (upsert by title); keeps
  # the original file as a downloadable attachment.
  class FolderImporter
    HTML_EXT   = %w[.html .htm].freeze
    MD_EXT     = %w[.md .markdown].freeze
    OFFICE_EXT = %w[.doc .docx .xls .xlsx .odt .ods .ppt .pptx].freeze
    SUPPORTED  = (HTML_EXT + MD_EXT + OFFICE_EXT).freeze

    def self.import(dir)
      new(dir).import
    end

    def initialize(dir)
      @dir = dir.to_s
    end

    def import
      return { imported: 0 } unless Dir.exist?(@dir)

      used = {}
      imported = 0
      Dir.glob(File.join(@dir, "*")).sort.each do |path|
        ext = File.extname(path).downcase
        next unless File.file?(path) && SUPPORTED.include?(ext)

        content = content_for(path, ext)
        next if content.blank?

        title = unique_title(title_for(path), ext, used)
        save_document(title, content, path, ext)
        imported += 1
      end
      { imported: imported }
    end

    private
      def save_document(title, content, path, ext)
        doc = Document.find_or_initialize_by(title: title, source: :uploaded_file)
        doc.doc_type = :uploaded
        doc.content = content
        doc.tag_list = "תיעוד, דוגמה" if doc.tag_list.blank?
        doc.save!
        return if doc.original.attached?

        doc.original.attach(io: File.open(path), filename: File.basename(path), content_type: content_type(ext))
      end

      # Text stored on the Document for search/preview. HTML documents are
      # displayed from their original file (see DocumentsController#raw), so we
      # only keep their plain text here; markdown/office produce markdown.
      def content_for(path, ext)
        raw = File.read(path).scrub("") # drop invalid UTF-8 bytes
        if MD_EXT.include?(ext)
          raw
        elsif HTML_EXT.include?(ext)
          html = Nokogiri::HTML(raw)
          html.css("head, style, script").remove
          (html.at_css("body") || html).text.gsub(/[ \t]+/, " ").gsub(/\n{3,}/, "\n\n").strip
        else
          Docs::OfficeConverter.new.convert(path, File.basename(path))
        end
      end

      def title_for(path)
        base = File.basename(path)
        hebrew = base.include?(".he.")
        name = base.sub(/\.he\.[^.]+$/i, "").sub(/\.[^.]+$/i, "")
        name = name.tr("_-", "  ").split.map(&:capitalize).join(" ")
        hebrew ? "#{name} (עברית)" : name
      end

      # Disambiguate files that share a base name but differ by format.
      def unique_title(title, ext, used)
        return tap_used(title, used) unless used.key?(title)

        fmt = MD_EXT.include?(ext) ? "Markdown" : ext.delete(".").upcase
        tap_used("#{title} (#{fmt})", used)
      end

      def tap_used(title, used)
        used[title] = true
        title
      end

      def content_type(ext)
        case ext
        when *MD_EXT then "text/markdown"
        when *HTML_EXT then "text/html"
        else "application/octet-stream"
        end
      end
  end
end
