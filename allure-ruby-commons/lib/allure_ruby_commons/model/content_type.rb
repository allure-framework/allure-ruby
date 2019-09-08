# frozen_string_literal: true

require "mime/types"

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
      MIME::Types[content_type]&.first&.preferred_extension
    end
  end
end
