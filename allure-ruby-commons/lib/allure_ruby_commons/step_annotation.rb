# frozen_string_literal: true

# Adds support for annotating methods as allure steps
#
module AllureStepAnnotation
  # Mark method definition as allure step
  #
  # @param [String] step_name
  # @return [void]
  def step(step_name = "")
    @allure_step = step_name
  end

  private

  def singleton_method_added(method_name)
    return super unless @allure_step

    original_method = singleton_method(method_name)
    step_name = @allure_step.empty? ? method_name.to_s : @allure_step
    @allure_step = nil

    define_singleton_method(method_name) do |*args, &block|
      Allure.run_step(step_name) { original_method.call(*args, &block) }
    end
  end

  def method_added(method_name)
    return super unless @allure_step

    original_method = instance_method(method_name)
    step_name = @allure_step.empty? ? method_name.to_s : @allure_step
    @allure_step = nil

    define_method(method_name) do |*args, &block|
      Allure.run_step(step_name) { original_method.bind_call(self, *args, &block) }
    end
  end
end
