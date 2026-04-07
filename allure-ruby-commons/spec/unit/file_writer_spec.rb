# frozen_string_literal: true

describe Allure::FileWriter do
  subject(:file_writer) { described_class.new(results_dir) }

  let(:results_dir) { "spec/allure-results" }

  before(:all) do
    clean_results_dir
  end

  it "writes test result container" do
    test_result_container = Allure::TestResultContainer.new
    json_file = File.join(results_dir, "#{test_result_container.uuid}-container.json")
    file_writer.write_test_result_container(test_result_container)

    expect(File.exist?(json_file)).to be_truthy, "Expected file to exist"
  end

  it "writes test result" do
    test_result = Allure::TestResult.new
    json_file = File.join(results_dir, "#{test_result.uuid}-result.json")
    file_writer.write_test_result(test_result)

    expect(File.exist?(json_file)).to be_truthy, "Expected file to exist"
  end

  it "writes string attachment" do
    attachment = Allure::Attachment.new(
      name: "Test attachment",
      type: Allure::ContentType::TXT,
      source: "#{SecureRandom.uuid}-attachment.txt"
    )
    attachment_file = File.join(results_dir, attachment.source)
    file_writer.write_attachment("Test attachment", attachment)

    expect(File.exist?(attachment_file)).to be_truthy, "Expected #{attachment_file} to exist"
  end

  it "writes image attachment" do
    attachment = Allure::Attachment.new(
      name: "Test attachment",
      type: Allure::ContentType::PNG,
      source: "#{SecureRandom.uuid}-attachment.png"
    )
    source = File.new(File.join(Dir.pwd, "spec", "fixtures", "ruby-logo.png"))
    attachment_file = File.join(results_dir, attachment.source)
    file_writer.write_attachment(source, attachment)

    expect(File.exist?(attachment_file)).to be_truthy, "Expected #{attachment_file} to exist"
  end

  it "writes globals chunk" do
    globals = Allure::Globals.new(
      attachments: [
        Allure::GlobalAttachment.new(
          name: "Global attachment",
          type: Allure::ContentType::TXT,
          source: "#{SecureRandom.uuid}-attachment.txt",
          timestamp: 123
        )
      ],
      errors: []
    )
    existing_files = Dir.glob(File.join(results_dir, "*-globals.json"))
    file_writer.write_globals(globals)

    globals_file = (Dir.glob(File.join(results_dir, "*-globals.json")) - existing_files).first

    aggregate_failures "Expected globals chunk to exist with correct content" do
      expect(globals_file).to be_a(String)
      expect(File.exist?(globals_file)).to be_truthy, "Expected #{globals_file} to exist"
      expect(file_writer.load_json(globals_file)).to eq(
        attachments: [
          {
            name: "Global attachment",
            type: Allure::ContentType::TXT,
            source: globals.attachments.first.source,
            timestamp: 123
          }
        ],
        errors: []
      )
    end
  end

  it "writes globals chunk with error" do
    globals = Allure::Globals.new(
      attachments: [],
      errors: [
        Allure::GlobalError.new(
          message: "Global failure",
          trace: "trace line",
          timestamp: 456
        )
      ]
    )
    existing_files = Dir.glob(File.join(results_dir, "*-globals.json"))
    file_writer.write_globals(globals)

    globals_file = (Dir.glob(File.join(results_dir, "*-globals.json")) - existing_files).first

    aggregate_failures "Expected globals error chunk to exist with correct content" do
      expect(globals_file).to be_a(String)
      expect(File.exist?(globals_file)).to be_truthy, "Expected #{globals_file} to exist"
      expect(file_writer.load_json(globals_file)).to eq(
        attachments: [],
        errors: [
          {
            known: false,
            muted: false,
            flaky: false,
            message: "Global failure",
            trace: "trace line",
            timestamp: 456
          }
        ]
      )
    end
  end

  it "writes environment properties" do
    environment_file = File.join(results_dir, "environment.properties")
    file_writer.write_environment(PROP1: "test", PROP2: "test_2")

    expect(File.exist?(environment_file)).to be_truthy, "Expected #{environment_file} to exist"
    expect(File.read(environment_file)).to eq(<<~FILE)
      PROP1=test
      PROP2=test_2
    FILE
  end

  it "writes categories from argument" do
    categories_file = File.join(results_dir, "categories.json")
    file_writer.write_categories(
      [Allure::Category.new(name: "Ignored test", matched_statuses: [Allure::Status::SKIPPED])]
    )

    expect(File.exist?(categories_file)).to be_truthy, "Expected #{categories_file} to exist"
    expect(File.read(categories_file)).to eq('[{"name":"Ignored test","matchedStatuses":["skipped"]}]')
  end

  it "writes categories from file" do
    categories_file = File.join(results_dir, "categories.json")
    file_writer.write_categories(File.new(File.join(Dir.pwd, "spec", "fixtures", "categories.json")))

    expect(File.exist?(categories_file)).to be_truthy, "Expected #{categories_file} to exist"
  end
end
