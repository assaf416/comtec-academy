require "open3"

module Media
  # Thin wrapper around the ffmpeg CLI. All media services shell out through here.
  module Ffmpeg
    BIN = ENV.fetch("FFMPEG_BIN", "ffmpeg")

    module_function

    def run(*args)
      cmd = [BIN, "-y", "-loglevel", "error", *args.map(&:to_s)]
      output, status = Open3.capture2e(*cmd)
      raise "ffmpeg failed (#{status.exitstatus}): #{output}" unless status.success?
      true
    end

    def available?
      _, status = Open3.capture2e(BIN, "-version")
      status.success?
    rescue Errno::ENOENT
      false
    end

    PROBE_BIN = ENV.fetch("FFPROBE_BIN", "ffprobe")

    def duration(path)
      out, status = Open3.capture2e(PROBE_BIN, "-v", "error",
                                    "-show_entries", "format=duration",
                                    "-of", "default=noprint_wrappers=1:nokey=1", path.to_s)
      status.success? ? out.strip.to_f : 0.0
    end
  end
end
