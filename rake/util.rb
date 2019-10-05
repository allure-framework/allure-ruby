# frozen_string_literal: true

require "colorize"
require "rake"
require "semantic"

module TaskUtil
  def root
    @root ||= File.expand_path("..", __dir__)
  end

  def adaptors
    @adaptors ||= Dir.glob("allure-*").select { |f| File.directory?(f) }
  end

  def version
    Semantic::Version.new(File.read("#{root}/ALLURE_VERSION").strip)
  end
end
