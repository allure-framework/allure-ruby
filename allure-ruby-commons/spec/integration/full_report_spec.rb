# frozen_string_literal: true

describe "allure-ruby-commons" do
  include_context "lifecycle"

  before(:all) do
    Allure.configure do |conf|
      conf.results_directory = "reports/allure-results/integration"
      conf.link_issue_pattern = "http://jira.com/{}"
      conf.link_tms_pattern = "http://jira.com/{}"
    end
    FileUtils.remove_dir(Allure::Config.results_directory) if File.exist?(Allure::Config.results_directory)
  end

  before do
    image = File.new(File.join(Dir.pwd, "spec/images/ruby-logo.png"))

    start_test_container("Result Container")
    add_fixture("Before", "prepare")

    start_test_case(name: "Some scenario", full_name: "feature: Some scenario")
    lifecycle.update_test_case do |test_case|
      test_case.links.push(
        Allure::Link.new("custom", "Custom Link", "http://www.custom-link.com"),
        Allure::ResultUtils.tms_link("QA-1"),
        Allure::ResultUtils.issue_link("DEV-1"),
      )
      test_case.labels.push(
        Allure::ResultUtils.suite_label("Some scenario"),
        Allure::ResultUtils.severity_label("blocker"),
      )
    end

    start_test_step(name: "Some step")
    lifecycle.update_test_step do |step|
      step.status = Allure::Status::FAILED
      step.status_details.message = "Fuuu, I failed"
      step.status_details.trace = "I failed because I cought an exception to the knee"
    end

    lifecycle.add_attachment(name: "Test Attachment", source: "string attachment", type: Allure::ContentType::TXT)

    lifecycle.stop_test_step

    lifecycle.update_test_case do |tc|
      tc.status = Allure::Status::FAILED
      tc.status_details.message = "Fuuu, I failed"
      tc.status_details.trace = "I failed because I cought an exception to the knee"
    end

    lifecycle.add_attachment(name: "Test Attachment", source: image, type: Allure::ContentType::PNG)

    lifecycle.stop_test_case

    add_fixture("After", "tear_down")

    lifecycle.stop_test_container
  end

  it "generate valid json", reporter: true do
    allure_cli = Allure::Util.allure_cli
    expect(`#{allure_cli} generate -c #{Allure::Config.results_directory} -o reports/allure-report`.chomp).to(
      eq("Report successfully generated to reports/allure-report"),
    )
  end
end
