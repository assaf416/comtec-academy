module Media
  # Turns a transcript into a simple SRT subtitle file spread evenly across the
  # given duration, so captions can be burned into the assembled movie.
  class CaptionBuilder
    def initialize(transcript, duration)
      @transcript = transcript.to_s.strip
      @duration = [ duration.to_f, 1.0 ].max
    end

    # Writes an .srt file and returns its path (or nil if there's no transcript).
    def write_to(path)
      return nil if @transcript.blank?

      File.open(path, "w") do |f|
        chunks.each_with_index do |chunk, i|
          starts = i * per_chunk
          ends = [ (i + 1) * per_chunk, @duration ].min
          f.puts(i + 1)
          f.puts("#{ts(starts)} --> #{ts(ends)}")
          f.puts(chunk)
          f.puts
        end
      end
      path
    end

    private
      def chunks
        @chunks ||= @transcript.scan(/\S.{0,80}\S(?=\s|\z)/m).presence || [ @transcript ]
      end

      def per_chunk
        @duration / chunks.size
      end

      def ts(seconds)
        ms = (seconds * 1000).round
        format("%02d:%02d:%02d,%03d", ms / 3_600_000, (ms / 60_000) % 60, (ms / 1000) % 60, ms % 1000)
      end
  end
end
