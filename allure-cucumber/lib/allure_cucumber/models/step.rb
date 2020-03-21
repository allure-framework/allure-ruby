# frozen_string_literal: true

module AllureCucumber
  class Step
    # @param [Cucumber::Core::Test::Step] test_step
    # @param [Cucumber::Formatter::AstLookup::StepSource] step_source
    def initialize(test_step, step_source)
      @test_step = test_step
      @step = step_source.step
    end

    def name
      @name ||= "#{step.keyword}#{step.text}"
    end

    def data_table
      @data_table ||= step.data_table
    end

    def doc_string
      @doc_string ||= step.doc_string
    end

    private

    attr_reader :test_step, :step
  end
end
