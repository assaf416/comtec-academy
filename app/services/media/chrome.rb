require "open3"

module Media
  # Headless Chrome wrapper — renders an HTML file to PDF with full CSS/RTL and
  # highlighted-code fidelity. Guarded so callers degrade gracefully when Chrome
  # is unavailable (e.g. CI).
  module Chrome
    BIN = ENV.fetch("CHROME_BIN", "google-chrome")

    module_function

    def available?
      _, status = Open3.capture2e(BIN, "--version")
      status.success?
    rescue Errno::ENOENT
      false
    end

    def to_pdf(html_path, out_pdf)
      cmd = [ BIN, "--headless=new", "--no-sandbox", "--disable-gpu", "--no-pdf-header-footer",
              "--run-all-compositor-stages-before-draw", "--virtual-time-budget=4000",
              "--print-to-pdf=#{out_pdf}", "file://#{html_path}" ]
      output, status = Open3.capture2e(*cmd)
      raise "chrome pdf failed: #{output}" unless status.success? && File.exist?(out_pdf)
      out_pdf
    end
  end
end
