require "open3"
require "tmpdir"
require "reverse_markdown"

module Docs
  # Converts an uploaded office file (Word/Excel) to markdown using LibreOffice
  # headless (file -> HTML) and reverse_markdown (HTML -> GFM). If LibreOffice
  # is unavailable or fails, returns a graceful placeholder so callers never
  # hard-fail (and CI without LibreOffice still works).
  class OfficeConverter
    BIN = ENV.fetch("SOFFICE_BIN", "soffice")

    def self.available?
      _, status = Open3.capture2e(BIN, "--version")
      status.success?
    rescue Errno::ENOENT
      false
    end

    # path: local path to the office file; filename: original name (for the title).
    def convert(path, filename)
      return fallback(filename) unless self.class.available?

      Dir.mktmpdir("office") do |dir|
        _, status = Open3.capture2e(BIN, "--headless", "--convert-to", "html",
                                    "--outdir", dir, path)
        html_file = Dir.glob(File.join(dir, "*.html")).first
        return fallback(filename) unless status.success? && html_file

        html = File.read(html_file).gsub(/<!--.*?-->/m, "") # drop LibreOffice HTML comments
        markdown = ReverseMarkdown.convert(html, github_flavored: true)
        markdown.strip.presence || fallback(filename)
      end
    rescue => e
      Rails.logger.warn("OfficeConverter failed for #{filename}: #{e.message}")
      fallback(filename)
    end

    private
      def fallback(filename)
        "# #{File.basename(filename, '.*')}\n\n" \
          "_ההמרה לא הושלמה. ניתן להוריד את הקובץ המקורי._\n"
      end
  end
end
