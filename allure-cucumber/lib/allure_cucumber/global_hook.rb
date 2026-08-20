# frozen_string_literal: true

require "cucumber/glue/hook"

module AllureCucumber
  # Captures Cucumber hooks outside the lifecycle of any scenario
  module GlobalHook
    HOOK_HANDLERS = {
      "BeforeAll" => :start_prepare_fixture,
      "AfterAll" => :start_tear_down_fixture
    }.freeze

    def self.install
      hook_class = Cucumber::Glue::Hook
      hook_class.prepend(Hook) unless hook_class < Hook
    end

    # Adds reporting around Cucumber BeforeAll and AfterAll hooks
    module Hook
      def invoke(pseudo_method, arguments, &)
        handler = HOOK_HANDLERS[pseudo_method]
        return super unless handler

        start_global_fixture(pseudo_method, handler)
        result = super
        Allure.lifecycle.update_fixture { |fixture| fixture.status = Allure::Status::PASSED }
        result
      rescue Exception => e # rubocop:disable Lint/RescueException
        update_failed_global_fixture(e) if handler
        raise
      ensure
        Allure.lifecycle.stop_fixture if handler
      end

      private

      def start_global_fixture(pseudo_method, handler)
        source = location.to_s.split("/").last
        name = "#{pseudo_method} hook (#{source})"
        Allure.lifecycle.public_send(handler, Allure::FixtureResult.new(name: name))
      end

      def update_failed_global_fixture(exception)
        Allure.lifecycle.update_fixture do |fixture|
          fixture.status = Allure::ResultUtils.status(exception)
          fixture.status_details = Allure::ResultUtils.status_details(exception)
        end
      end
    end
  end
end

AllureCucumber::GlobalHook.install
