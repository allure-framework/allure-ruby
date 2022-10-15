# frozen_string_literal: true

require "semver"

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

      puts "Updating version to #{new_version}"

      update_version
      update_lockfile
      commit_and_tag

      puts "Version updated successfully!"
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
    execute_shell("git add #{VERSION_FILE} #{LOCKFILE}")
    execute_shell("git commit -m 'Update version to #{new_version}'")
    execute_shell("git tag #{new_version}")
    execute_shell("git push && git push --tags")
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
