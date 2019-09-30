# frozen_string_literal: true

require "open-uri"
require "zip"
require "pathname"

module Allure
  # Utility for downloading allure commandline binary
  class Util
    # @return [String] CLI version
    ALLURE_CLI_VERSION = "2.13.0"
    # @return [String] CLI bin download url
    ALLURE_BIN_URL = "http://repo.maven.apache.org/maven2/io/qameta/allure/allure-commandline/"\
                      "#{ALLURE_CLI_VERSION}/allure-commandline-#{ALLURE_CLI_VERSION}.zip"

    class << self
      # Download allure bin if appropriate version is not in path
      # @return [String] allure executable
      def allure_cli
        return "allure" if ALLURE_CLI_VERSION == `allure --version`.chomp

        cli_dir = File.join(".allure", "allure-#{ALLURE_CLI_VERSION}")
        zip = File.join(".allure", "allure.zip")
        bin = File.join(cli_dir, "bin", "allure")

        FileUtils.mkpath(".allure")
        download_allure(zip) unless File.exist?(zip) || File.exist?(bin)
        extract_allure(zip, ".allure") unless File.exist?(bin)

        bin
      end

      private

      def download_allure(destination)
        File.open(destination, "w") { |file| file.write(open(ALLURE_BIN_URL).read) } # rubocop:disable Security/Open
      end

      def extract_allure(zip, destination)
        Zip::File.foreach(zip) do |entry|
          entry.restore_permissions = true
          entry.extract(File.join(destination, entry.name))
        end
        FileUtils.rm(zip)
      end
    end
  end
end
