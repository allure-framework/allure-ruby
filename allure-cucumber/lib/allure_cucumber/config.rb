# frozen_string_literal: true

module Allure
  class CucumberConfig < Config
    class << self
      DEFAULT_TMS_PREFIX = "TMS:"
      DEFAULT_ISSUE_PREFIX = "ISSUE:"
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
