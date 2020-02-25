# frozen_string_literal: true

class CodeClimateUploader
  CC_REPORTER_URL = "https://codeclimate.com/downloads/test-reporter/test-reporter-0.6.3-linux-amd64"
  CC_REPORTER = "vendor/bundle/cc_reporter_0.6.3"
  CC_JSON = "codeclimate.json"
  SIMPLECOV_RESULT = "coverage/.resultset.json"

  class << self
    def upload
      download_reporter
      format_coverage
      upload_coverage
    end

    private

    def format_coverage
      system(cc_env, "./#{CC_REPORTER} format-coverage #{SIMPLECOV_RESULT} -t simplecov -o #{CC_JSON}")
    end

    def upload_coverage
      system(cc_env, "./#{CC_REPORTER} upload-coverage -i #{CC_JSON}")
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

      system("curl -s -L #{CC_REPORTER_URL} -o #{CC_REPORTER} && chmod a+x #{CC_REPORTER}")
    end
  end
end
