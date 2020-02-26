# frozen_string_literal: true

require "semantic"

class VersionUpdater
  extend TaskUtil
  extend Rake::DSL

  class << self
    def update(increment, push)
      @version = Semantic::Version.new(File.read("#{root}/ALLURE_VERSION").strip)
      @new_version = @version.increment!(increment || "patch")

      update_allure_version
      update_lock
      commit
      push_to_origin if push
    end

    private

    def update_allure_version
      File.write("#{root}/ALLURE_VERSION", @new_version, mode: "w")
    end

    def update_lock
      lockfile = "#{root}/Gemfile.lock"
      File.write(lockfile, File.read(lockfile).gsub(/#{@version}/, @new_version.to_s), mode: "w")
    end

    def commit
      puts "Updating version to #{@new_version}".yellow
      sh("git commit ALLURE_VERSION Gemfile.lock -m 'Update allure to v#{@new_version}'")
      sh("git tag #{@new_version}")
    end

    def push_to_origin
      puts "Pushing changes to repository".yellow
      sh("git push origin HEAD && git push origin #{@new_version}")
    end
  end
end
