# frozen_string_literal: true

module Allure
  class FileWriter
    TEST_RESULT_SUFFIX = "-result.json"
    TEST_RESULT_CONTAINER_SUFFIX = "-container.json"
    ATTACHMENT_FILE_SUFFIX = "-attachment"

    # Write test result
    # @param [Allure::TestResult] test_result
    # @return [void]
    def write_test_result(test_result)
      write("#{test_result.uuid}#{TEST_RESULT_SUFFIX}", test_result.to_json)
    end

    # Write test result container
    # @param [Allure::TestResultContainer] test_container_result
    # @return [void]
    def write_test_result_container(test_container_result)
      write("#{test_container_result.uuid}#{TEST_RESULT_CONTAINER_SUFFIX}", test_container_result.to_json)
    end

    # Write allure attachment file
    # @param [File, String] source File or string of attachment to save
    # @param [Allure::Attachment] attachment
    # @return [void]
    def write_attachment(source, attachment)
      source.is_a?(File) ? copy(source.path, attachment.source) : write(attachment.source, source)
    end

    private

    def output_dir
      @output_dir ||= FileUtils.mkpath(Allure::Config.results_directory).first
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
