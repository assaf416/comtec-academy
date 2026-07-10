# Generate absolute URLs (invitation links) and run jobs/mail synchronously
# during acceptance tests.
Rails.application.routes.default_url_options[:host] = "localhost"
ActionMailer::Base.default_url_options = { host: "localhost" }
ActiveJob::Base.queue_adapter = :inline

# Fixed shared secret for the documents API during tests.
ENV["DOCS_API_KEY"] = "test-docs-key"
