# frozen_string_literal: true

module AllureCucumber
  # Allure cucumber configuration
  class CucumberConfig
    class << self
      # @return [String] default tms tag prefix
      DEFAULT_TMS_PREFIX = "TMS:"
      # @return [String] default issue tag prefix
      DEFAULT_ISSUE_PREFIX = "ISSUE:"
      # @return [String] default severity tag prefix
      DEFAULT_SEVERITY_PREFIX = "SEVERITY:"

      attr_writer :tms_prefix, :issue_prefix, :severity_prefix

      # @return [String]
      def tms_prefix
        @tms_prefix || DEFAULT_TMS_PREFIX
      end

      # @return [String]
      def issue_prefix
        @issue_prefix || DEFAULT_ISSUE_PREFIX
      end

      # @return [String]
      def severity_prefix
        @severity_prefix || DEFAULT_SEVERITY_PREFIX
      end
    end
  end
end
