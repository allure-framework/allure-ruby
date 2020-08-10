# frozen_string_literal: true

module Allure
  # Allure result file writer
  class FileWriter
    # @return [String] test result suffix
    TEST_RESULT_SUFFIX = "-result.json"
    # @return [String] test result container suffix
    TEST_RESULT_CONTAINER_SUFFIX = "-container.json"
    # @return [String] attachment file suffix
    ATTACHMENT_FILE_SUFFIX = "-attachment"
    # @return [String] environment info file
    ENVIRONMENT_FILE = "environment.properties"
    # @return [String] categories definition json
    CATEGORIES_FILE = "categories.json"

    # Write test result
    # @param [Allure::TestResult] test_result
    # @return [void]
    def write_test_result(test_result)
      write("#{test_result.uuid}#{TEST_RESULT_SUFFIX}", JSON.generate(test_result, max_nesting: false))
    end

    # Write test result container
    # @param [Allure::TestResultContainer] test_container_result
    # @return [void]
    def write_test_result_container(test_container_result)
      write(
        "#{test_container_result.uuid}#{TEST_RESULT_CONTAINER_SUFFIX}",
        JSON.generate(test_container_result, max_nesting: false),
      )
    end

    # Write allure attachment file
    # @param [File, String] source File or string of attachment to save
    # @param [Allure::Attachment] attachment
    # @return [void]
    def write_attachment(source, attachment)
      source.is_a?(File) ? copy(source.path, attachment.source) : write(attachment.source, source)
    end

    # Write allure report environment info
    # @param [Hash<Symbol, String>] environment
    # @return [void]
    def write_environment(environment)
      environment.reduce("") { |e, (k, v)| e + "#{k}=#{v}\n" }.tap do |env|
        write(ENVIRONMENT_FILE, env)
      end
    end

    # Write categories info
    # @param [File, Array<Allure::Category>] categories
    # @return [void]
    def write_categories(categories)
      if categories.is_a?(File)
        copy(categories.path, CATEGORIES_FILE)
      else
        write(CATEGORIES_FILE, categories.to_json)
      end
    end

    private

    def output_dir
      @output_dir ||= FileUtils.mkpath(Config.instance.results_directory).first
    end

    def write(name, source)
      filename = File.join(output_dir, name)
      File.open(filename, "w") { |file| file.write(source) }
    end

    def copy(from, to)
      FileUtils.cp(from, File.join(output_dir, to))
    end
  end
end
