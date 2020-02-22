# frozen_string_literal: true

return unless ENV["COVERAGE"] && !ENV["COV_MERGE"]

SimpleCov.start do
  add_filter ["/spec/", "/fixture/", "/features/"]
  minimum_coverage 95
  formatter SimpleCov::Formatter::SimpleFormatter
end
