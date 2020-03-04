# frozen_string_literal: true

class CodeClimateUploader
  CC_REPORTER_VERSION = "0.7.0"
  CC_REPORTER_URL = "https://codeclimate.com/downloads/test-reporter/test-reporter-#{CC_REPORTER_VERSION}-linux-amd64"
  CC_REPORTER = "vendor/bundle/cc_reporter_#{CC_REPORTER_VERSION}"
  CC_JSON = "coverage/codeclimate.json"

  class << self
    def upload(simplecov_result)
      download_reporter
      format_coverage(simplecov_result)
      upload_coverage
    end

    private

    def format_coverage(simplecov_result)
      shell("./#{CC_REPORTER} format-coverage #{simplecov_result} -t simplecov -o #{CC_JSON}", cc_env)
    end

    def upload_coverage
      shell("./#{CC_REPORTER} upload-coverage -i #{CC_JSON}", cc_env)
    end

    def cc_env
      @cc_env ||= {
        "GIT_COMMIT_SHA" => pull_request? ? context.event.pull_request.head.sha : context.sha,
        "GIT_BRANCH" => pull_request? ? ENV["GITHUB_HEAD_REF"] : ENV["GITHUB_REF"].split("/").last,
        "CI_NAME" => "github-actions",
      }
    end

    def context
      @context ||= JSON.parse(ENV["CONTEXT"], object_class: OpenStruct)
    end

    def pull_request?
      @pull_request ||= ENV["GITHUB_EVENT_NAME"] == "pull_request"
    end

    def download_reporter
      return if File.exist?(CC_REPORTER)

      shell("curl -s -L #{CC_REPORTER_URL} -o #{CC_REPORTER} && chmod a+x #{CC_REPORTER}")
    end

    def shell(cmd, env = {})
      status = system(env, cmd)
      raise StandardError.new("Command failed") unless status
    end
  end
end
