# frozen_string_literal: true

require_relative "rake/test"
require_relative "rake/release"

task default: "all:test"

desc "Run rubocop for all adaptors"
task rubocop: "all:rubocop"

desc "Run all tests"
task test: "all:test"

desc "Clean gem files from pkg folder"
task clean: "all:clean"

desc "Build ruby gems for all adaptors"
task build: "all:build"

desc "Build and push ruby gems to registry for all adaptors"
task release: "all:release"
