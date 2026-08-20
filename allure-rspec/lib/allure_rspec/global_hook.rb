# frozen_string_literal: true

module AllureRspec
  # Captures suite hook results outside the lifecycle of any example
  module GlobalHook
    HOOK_TYPES = {
      before: ["Before suite hook", :start_prepare_fixture],
      after: ["After suite hook", :start_tear_down_fixture]
    }.freeze

    class << self
      def install
        RSpec::Core::Hooks::BeforeHook.prepend(BeforeHook) unless RSpec::Core::Hooks::BeforeHook < BeforeHook
        RSpec::Core::Hooks::AfterHook.prepend(AfterHook) unless RSpec::Core::Hooks::AfterHook < AfterHook
      end

      def start(hook, type)
        name, handler = HOOK_TYPES.fetch(type)
        location = hook.block.source_location&.join(":")
        fixture_name = location ? "#{name} (#{location})" : name
        fixture = Allure::FixtureResult.new(name: fixture_name)
        Allure.lifecycle.public_send(handler, fixture)
      end

      def pass
        Allure.lifecycle.update_fixture { |fixture| fixture.status = Allure::Status::PASSED }
      end

      def fail(exception)
        Allure.lifecycle.update_fixture do |fixture|
          fixture.status = Allure::ResultUtils.status(exception)
          fixture.status_details = Allure::ResultUtils.status_details(exception)
        end
      end

      def stop
        Allure.lifecycle.stop_fixture
      end

      def suite_hook?(hook, type)
        hooks = RSpec.configuration.instance_variable_get(:"@#{type}_suite_hooks")
        hooks&.include?(hook)
      end
    end

    # Adds reporting around RSpec before(:suite) hooks
    module BeforeHook
      def run(example)
        global_hook = GlobalHook.suite_hook?(self, :before)
        return super unless global_hook

        GlobalHook.start(self, :before)
        super
        GlobalHook.pass
      rescue RSpec::Support::AllExceptionsExceptOnesWeMustNotRescue => e
        GlobalHook.fail(e)
        raise
      ensure
        GlobalHook.stop if global_hook
      end
    end

    # Adds reporting around RSpec after(:suite) hooks
    module AfterHook
      def run(example)
        global_hook = GlobalHook.suite_hook?(self, :after)
        return super unless global_hook

        GlobalHook.start(self, :after)
        example.instance_exec(example, &block)
        GlobalHook.pass
      rescue RSpec::Support::AllExceptionsExceptOnesWeMustNotRescue => e
        GlobalHook.fail(e)
        example.set_exception(e)
      ensure
        GlobalHook.stop if global_hook
      end
    end
  end
end
