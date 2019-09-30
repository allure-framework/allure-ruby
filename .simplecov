# frozen_string_literal: true

SimpleCov.start { add_filter ["/spec/", "/fixture/", "/features/"] } unless ENV["COVERAGE"]
