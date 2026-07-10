module Admin
  class UploadsController < BaseController
    def new
      @document = Document.new
    end

    # Accept an office file, keep the original, and convert it to markdown.
    def create
      file = params[:file]
      if file.blank?
        redirect_to new_admin_upload_path, alert: t("admin.uploads.missing_file") and return
      end

      @document = Document.new(
        source: :uploaded_file,
        doc_type: :uploaded,
        title: File.basename(file.original_filename, ".*")
      )
      @document.original.attach(file)

      if @document.save
        ConvertOfficeDocumentJob.perform_later(@document)
        redirect_to document_path(@document), notice: t("admin.uploads.uploaded")
      else
        redirect_to new_admin_upload_path, alert: @document.errors.full_messages.to_sentence
      end
    end
  end
end
