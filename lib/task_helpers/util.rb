# frozen_string_literal: true

require "colorize"
require "open3"

module TaskUtil
  def root
    @root ||= File.expand_path("../..", __dir__)
  end

  def adaptors
    @adaptors ||= Dir.glob("allure-*").select { |f| File.directory?(f) }
  end

  def version
    @version ||= File.read("#{root}/ALLURE_VERSION").strip
  end

  # Execute shell command
  #
  # @param [String] command
  # @return [String] output
  def execute_shell(command)
    out, err, status = Open3.capture3(command)
    raise("Out:\n#{out}\n\nErr:\n#{err}") unless status.success?

    out
  end
end
