# frozen_string_literal: true

require "socket"

module Allure
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

      # Feature label
      # @param [String] value
      # @return [Allure::Label]
      def feature_label(value)
        Label.new(FEATURE_LABEL_NAME, value)
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

      # Story label
      # @param [String] value
      # @return [Allure::Label]
      def story_label(value)
        Label.new(STORY_LABEL_NAME, value)
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
      # @return [Allure::Link]
      def tms_link(value)
        Link.new(TMS_LINK_TYPE, value, tms_url(value))
      end

      # Issue link
      # @param [String] value
      # @return [Allure::Link]
      def issue_link(value)
        Link.new(ISSUE_LINK_TYPE, value, issue_url(value))
      end

      # Get status based on exception type
      # @param [Exception] exception
      # @return [String]
      def status(exception)
        expectation_error?(exception) ? Status::FAILED : Status::BROKEN
      end

      # Get exception status detail
      # @param [Exception] exception
      # @return [Hash<Symbol, String>]
      def status_details(exception)
        { message: exception.message, trace: exception.backtrace&.join("\n") }
      end

      private

      def tms_url(value)
        Allure.configuration.link_tms_pattern.sub("{}", value)
      end

      def issue_url(value)
        Allure.configuration.link_issue_pattern.sub("{}", value)
      end

      def expectation_error?(exception)
        exception.instance_of?(RSpec::Expectations::ExpectationNotMetError) ||
          exception.instance_of?(RSpec::Expectations::MultipleExpectationsNotMetError)
      rescue NameError
        false
      end
    end
  end
end
