module Ai
  # Keyword retrieval over shared snippets and documents, so the code chat can
  # pull relevant code from across Comtec's projects (AS/400 COBOL, C#, web) —
  # not only the file currently open. Runs entirely locally (SQL LIKE); an
  # embeddings backend can replace `#matches` later without changing callers.
  class CodeRetriever
    def initialize(limit: 5)
      @limit = limit
    end

    # Returns related snippets + documents matching any 3+ char term in the query.
    # `exclude` (the snippet being viewed) is never returned.
    def search(query, exclude: nil)
      terms = query.to_s.scan(/[[:alnum:]]{3,}/).uniq.first(8)
      return [] if terms.empty?

      (snippets(terms, exclude) + documents(terms)).first(@limit)
    end

    private
      def snippets(terms, exclude)
        rel = Snippet.all
        rel = rel.where.not(id: exclude.id) if exclude.is_a?(Snippet)
        matches(rel, terms, %w[title body description]).recent.limit(@limit).to_a
      end

      def documents(terms)
        matches(Document.all, terms, %w[title tags]).order(updated_at: :desc).limit(@limit).to_a
      end

      def matches(rel, terms, cols)
        clause = terms.map { cols.map { |c| "#{c} LIKE ?" }.join(" OR ") }.join(" OR ")
        args = terms.flat_map { |t| [ "%#{ActiveRecord::Base.sanitize_sql_like(t)}%" ] * cols.size }
        rel.where(clause, *args)
      end
  end
end
