# frozen_string_literal: true

module Allure
  # Commonly used mime type definitions
  class ContentType
    TXT = "text/plain"
    XML = "application/xml"
    CSV = "text/csv"
    TSV = "text/tab-separated-values"
    CSS = "text/css"
    URI = "text/uri-list"
    SVG = "image/svg+xml"
    PNG = "image/png"
    JSON = "application/json"
    WEBM = "video/webm"
    JPG = "image/jpeg"

    # Get file extension from mime type
    # @param [String] content_type mime type
    # @return [String] file extension
    def self.to_extension(content_type)
      constants.detect { |const| const_get(const) == content_type }&.to_s&.downcase
    end
  end
end
