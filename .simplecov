# frozen_string_literal: true

return unless ENV["COVERAGE"] && !ENV["COV_MERGE"]

SimpleCov.configure do
  skip ["/spec/", "/tmp/"]
  minimum_coverage 95
  enable_coverage :branch
  formatter ENV["COV_HTML_REPORT"] ? SimpleCov::Formatter::HTMLFormatter : SimpleCov::Formatter::SimpleFormatter
end
