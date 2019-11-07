# frozen_string_literal: true

require "colorize"
require "rake"

module TaskUtil
  def root
    @root ||= File.expand_path("..", __dir__)
  end

  def adaptors
    @adaptors ||= Dir.glob("allure-*").select { |f| File.directory?(f) }
  end

  def version
    ENV["VERSION"] || File.read("#{root}/LOCAL_VERSION").strip
  end
end
