# frozen_string_literal: true

require_relative "tasks/test"
require_relative "tasks/release"

desc "Run all tests by default"
task default: :test

desc "Build gem files for all projects"
task build: "all:build"

desc "Release all gems to rubygems"
task release: "all:push"
