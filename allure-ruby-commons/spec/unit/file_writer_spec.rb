# frozen_string_literal: true

describe Allure::FileWriter do
  let(:file_writer) { Allure::FileWriter.new }

  before(:all) do
    clean_results_dir
  end

  it "writes test result container" do
    test_result_container = Allure::TestResultContainer.new
    json_file = File.join(Allure.configuration.results_directory, "#{test_result_container.uuid}-container.json")
    file_writer.write_test_result_container(test_result_container)

    expect(File.exist?(json_file)).to be_truthy, "Expected file to exist"
  end

  it "writes test result" do
    test_result = Allure::TestResult.new
    json_file = File.join(Allure.configuration.results_directory, "#{test_result.uuid}-result.json")
    file_writer.write_test_result(test_result)

    expect(File.exist?(json_file)).to be_truthy, "Expected file to exist"
  end

  it "writes string attachment" do
    attachment = Allure::Attachment.new(
      name: "Test attachment",
      type: Allure::ContentType::TXT,
      source: "#{UUID.generate}-attachment.txt"
    )
    attachment_file = File.join(Allure.configuration.results_directory, attachment.source)
    file_writer.write_attachment("Test attachment", attachment)

    expect(File.exist?(attachment_file)).to be_truthy, "Expected #{attachment_file} to exist"
  end

  it "writes image attachment" do
    attachment = Allure::Attachment.new(
      name: "Test attachment",
      type: Allure::ContentType::PNG,
      source: "#{UUID.generate}-attachment.png"
    )
    source = File.new(File.join(Dir.pwd, "spec", "fixtures", "ruby-logo.png"))
    attachment_file = File.join(Allure.configuration.results_directory, attachment.source)
    file_writer.write_attachment(source, attachment)

    expect(File.exist?(attachment_file)).to be_truthy, "Expected #{attachment_file} to exist"
  end

  it "writes environment properties" do
    environment_file = File.join(Allure.configuration.results_directory, "environment.properties")
    file_writer.write_environment(PROP1: "test", PROP2: "test_2")

    expect(File.exist?(environment_file)).to be_truthy, "Expected #{environment_file} to exist"
    expect(File.read(environment_file)).to eq(<<~FILE)
      PROP1=test
      PROP2=test_2
    FILE
  end

  it "writes categories from argument" do
    categories_file = File.join(Allure.configuration.results_directory, "categories.json")
    file_writer.write_categories(
      [Allure::Category.new(name: "Ignored test", matched_statuses: [Allure::Status::SKIPPED])]
    )

    expect(File.exist?(categories_file)).to be_truthy, "Expected #{categories_file} to exist"
    expect(File.read(categories_file)).to eq('[{"name":"Ignored test","matchedStatuses":["skipped"]}]')
  end

  it "writes categories from file" do
    categories_file = File.join(Allure.configuration.results_directory, "categories.json")
    file_writer.write_categories(File.new(File.join(Dir.pwd, "spec", "fixtures", "categories.json")))

    expect(File.exist?(categories_file)).to be_truthy, "Expected #{categories_file} to exist"
  end
end
