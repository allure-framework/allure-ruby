# frozen_string_literal: true

require "socket"
require "uri"

module Allure
  # Variouse helper methods
  module ResultUtils
    ISSUE_LINK_TYPE = "issue"
    TMS_LINK_TYPE = "tms"

    ALLURE_ID_LABEL_NAME = "AS_ID"
    SUITE_LABEL_NAME = "suite"
    PARENT_SUITE_LABEL_NAME = "parentSuite"
    SUB_SUITE_LABEL_NAME = "subSuite"
    EPIC_LABEL_NAME = "epic"
    FEATURE_LABEL_NAME = "feature"
    STORY_LABEL_NAME = "story"
    SEVERITY_LABEL_NAME = "severity"
    TAG_LABEL_NAME = "tag"
    OWNER_LABEL_NAME = "owner"
    LEAD_LABEL_NAME = "lead"
    HOST_LABEL_NAME = "host"
    THREAD_LABEL_NAME = "thread"
    TEST_METHOD_LABEL_NAME = "testMethod"
    TEST_CLASS_LABEL_NAME = "testClass"
    PACKAGE_LABEL_NAME = "package"
    FRAMEWORK_LABEL_NAME = "framework"
    LANGUAGE_LABEL_NAME = "language"

    class << self
      # @param [Time] time
      # @return [Number]
      def timestamp(time = nil)
        ((time || Time.now).to_f * 1000).to_i
      end

      # Current thread label
      # @return [Allure::Label]
      def thread_label
        Label.new(THREAD_LABEL_NAME, Thread.current.object_id)
      end

      # Host label
      # @return [Allure::Label]
      def host_label
        Label.new(HOST_LABEL_NAME, Socket.gethostname)
      end

      # Language label
      # @return [Allure::Label]
      def language_label
        Label.new(LANGUAGE_LABEL_NAME, "ruby")
      end

      # Framework label
      # @param [String] value
      # @return [Allure::Label]
      def framework_label(value)
        Label.new(FRAMEWORK_LABEL_NAME, value)
      end

      # Epic label
      # @param [String] value
      # @return [Allure::Label]
      def epic_label(value)
        Label.new(EPIC_LABEL_NAME, value)
      end

      # Feature label
      # @param [String] value
      # @return [Allure::Label]
      def feature_label(value)
        Label.new(FEATURE_LABEL_NAME, value)
      end

      # Story label
      # @param [String] value
      # @return [Allure::Label]
      def story_label(value)
        Label.new(STORY_LABEL_NAME, value)
      end

      # Package label
      # @param [String] value
      # @return [Allure::Label]
      def package_label(value)
        Label.new(PACKAGE_LABEL_NAME, value)
      end

      # Suite label
      # @param [String] value
      # @return [Allure::Label]
      def suite_label(value)
        Label.new(SUITE_LABEL_NAME, value)
      end

      # Parent suite label
      # @param [String] value
      # @return [Allure::Label]
      def parent_suite_label(value)
        Label.new(PARENT_SUITE_LABEL_NAME, value)
      end

      # Parent suite label
      # @param [String] value
      # @return [Allure::Label]
      def sub_suite_label(value)
        Label.new(SUB_SUITE_LABEL_NAME, value)
      end

      # Test case label
      # @param [String] value
      # @return [Allure::Label]
      def test_class_label(value)
        Label.new(TEST_CLASS_LABEL_NAME, value)
      end

      # Tag label
      # @param [String] value
      # @return [Allure::Label]
      def tag_label(value)
        Label.new(TAG_LABEL_NAME, value)
      end

      # Severity label
      # @param [String] value
      # @return [Allure::Label]
      def severity_label(value)
        Label.new(SEVERITY_LABEL_NAME, value)
      end

      # TMS link
      # @param [String] value
      # @param [String] link_pattern
      # @return [Allure::Link]
      def tms_link(name, value, link_pattern)
        link_name = url?(value) ? name : value
        Link.new(TMS_LINK_TYPE, link_name, url(value, link_pattern))
      end

      # Issue link
      # @param [String] value
      # @param [String] link_pattern
      # @return [Allure::Link]
      def issue_link(name, value, link_pattern)
        link_name = url?(value) ? name : value
        Link.new(ISSUE_LINK_TYPE, link_name, url(value, link_pattern))
      end

      # Get status based on exception type
      # @param [Exception] exception
      # @return [Symbol]
      def status(exception)
        exception.is_a?(RSpec::Expectations::ExpectationNotMetError) ? Status::FAILED : Status::BROKEN
      end

      # Get exception status detail
      # @param [Exception] exception
      # @return [Allure::StatusDetails]
      def status_details(exception)
        StatusDetails.new(message: exception&.message, trace: exception&.backtrace&.join("\n"))
      end

      # Allure attachment object
      # @param [String] name
      # @param [String] type
      # @return [Allure::Attachment]
      def prepare_attachment(name, type)
        extension = ContentType.to_extension(type) || return
        file_name = "#{UUID.generate}-attachment.#{extension}"
        Attachment.new(name: name, source: file_name, type: type)
      end

      private

      # Check if value is full url
      #
      # @param [String] value
      # @return [Boolean]
      def url?(value)
        URI.parse(value.to_s).scheme
      end

      # Construct url from pattern
      #
      # @param [String] value
      # @param [String] link_pattern
      # @return [String]
      def url(value, link_pattern)
        link_pattern.sub("{}", value)
      end
    end
  end
end
