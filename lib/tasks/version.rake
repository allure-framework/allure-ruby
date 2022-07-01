# frozen_string_literal: true

require "semver"
require "git"

require_relative "../task_helpers/util"

# Update app version
#
class VersionTask
  include Rake::DSL
  include TaskUtil

  VERSION_FILE = "ALLURE_VERSION"
  LOCKFILE = "Gemfile.lock"

  def initialize
    @version = File.read(VERSION_FILE)

    add_version_task
  end

  # Add version bump task
  #
  def add_version_task
    desc("Bump application version [major, minor, patch]")
    task(:version, [:semver]) do |_task, args|
      @new_version = send(args[:semver]).format("%M.%m.%p").to_s

      update_version
      update_lockfile
      commit_and_tag

      puts "Bumped version to #{new_version}"
    end
  end

  private

  attr_reader :version, :new_version

  # Update version file
  #
  # @return [void]
  def update_version
    File.write(VERSION_FILE, new_version)
  end

  # Update lock file
  #
  # @return [void]
  def update_lockfile
    execute_shell("bundle install")
  end

  # Commit updated version file and Gemfile.lock
  #
  # @return [void]
  def commit_and_tag
    git = Git.init
    git.add([VERSION_FILE, LOCKFILE])
    git.commit("Update version to #{new_version}")
    git.add_tag(new_version.to_s)
  end

  # Semver of ref from
  #
  # @return [SemVer]
  def semver
    @semver ||= SemVer.parse(version)
  end

  # Increase patch version
  #
  # @return [SemVer]
  def patch
    semver.tap { |ver| ver.patch += 1 }
  end

  # Increase minor version
  #
  # @return [SemVer]
  def minor
    semver.tap do |ver|
      ver.minor += 1
      ver.patch = 0
    end
  end

  # Increase major version
  #
  # @return [SemVer]
  def major
    semver.tap do |ver|
      ver.major += 1
      ver.minor = 0
      ver.patch = 0
    end
  end
end

VersionTask.new
