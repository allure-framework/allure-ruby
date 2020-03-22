# frozen_string_literal: true

module AllureCucumber
  # Cucumber step wrapper class
  class Step
    # @param [Cucumber::Formatter::AstLookup::StepSource] step_source
    def initialize(step_source)
      @step = step_source.step
    end

    # Step name
    # @return [String]
    def name
      @name ||= "#{step.keyword}#{step.text}"
    end

    # Step data table
    # @return [Cucumber::Messages::GherkinDocument::Feature::Step::DataTable]
    def data_table
      @data_table ||= step.data_table
    end

    # Step docstring
    # @return [String]
    def doc_string
      @doc_string ||= step.doc_string
    end

    private

    attr_reader :step
  end
end
