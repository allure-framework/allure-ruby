# frozen_string_literal: true

return if ENV["COVERAGE"]

SimpleCov.start do 
  add_filter ["/spec/", "/fixture/", "/features/"]
  minimum_coverage 95
end
