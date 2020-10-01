# frozen_string_literal: true

describe "allure-ruby-commons" do
  include_context "lifecycle"

  let(:results_dir) { Allure.configuration.results_directory }

  before(:all) do
    clean_results_dir
  end

  before do
    image = File.new(File.join(Dir.pwd, "spec/fixtures/ruby-logo.png"))

    Allure.add_environment(TYPE: "integration", spec: "allure-ruby-commons")

    start_test_container("Result Container")
    add_fixture("Before", "prepare")

    start_test_case(name: "Some scenario", full_name: "feature: Some scenario")
    lifecycle.update_test_case do |test_case|
      test_case.links.push(
        Allure::Link.new("custom", "Custom Link", "http://www.custom-link.com"),
        Allure::ResultUtils.tms_link("QA-1"),
        Allure::ResultUtils.issue_link("DEV-1")
      )
      test_case.labels.push(
        Allure::ResultUtils.suite_label("Some scenario"),
        Allure::ResultUtils.severity_label("blocker")
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

  it "generate valid json", integration: true do
    container = File.new(Dir["#{results_dir}/*container.json"].first)
    result = File.new(Dir["#{results_dir}/*result.json"].first)
    attachments = Dir["#{results_dir}/*attachment*"]
    environment = File.join(results_dir, "environment.properties")

    aggregate_failures "Results files should exist" do
      expect(File.exist?(container)).to be_truthy
      expect(File.exist?(result)).to be_truthy
      expect(File.exist?(environment)).to be_truthy
      expect(File.exist?(attachments[0])).to be_truthy
      expect(File.exist?(attachments[1])).to be_truthy
    end

    container_json = JSON.parse(File.read(container), symbolize_names: true)
    result_json = JSON.parse(File.read(result), symbolize_names: true)

    aggregate_failures "Json results should contain valid data" do
      expect(container_json[:name]).to eq("Result Container")
      expect(result_json[:fullName]).to eq("feature: Some scenario")
      expect(result_json[:steps].size).to eq(1)
    end
  end
end
