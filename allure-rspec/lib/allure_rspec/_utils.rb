# frozen_string_literal: true

module AllureRspec
  module Utils
    # Match reported full names through RSpec's metadata filter API.
    # @param [Set<String>] names
    # @return [Proc]
    def self.full_name_filter(names)
      lambda do |file_path, metadata|
        names.include?(Allure::ResultUtils.full_name(file_path, metadata[:full_description]))
      end
    end

    # Strip relative ./ form path
    # @param [String] path
    # @return [String]
    def strip_relative(path)
      path.gsub("./", "")
    end
  end
end
