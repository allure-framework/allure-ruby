# frozen_string_literal: true

module AllureRspec
  module Utils
    # Strip relative ./ form path
    # @param [String] path
    # @return [String]
    def strip_relative(path)
      path.gsub("./", "")
    end
  end
end
