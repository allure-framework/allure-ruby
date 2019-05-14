# frozen_string_literal: true

module Allure
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

    def self.to_extension(content_type)
      constants.detect { |const| const_get(const) == content_type }&.to_s&.downcase
    end
  end
end
