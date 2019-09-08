# frozen_string_literal: true

describe "Lifecycle:Attachments" do
  include_context "lifecycle"
  include_context "lifecycle mocks"

  let(:attach_opts) do
    {
      name: "Test Attachment",
      source: "string attachment",
      type: Allure::ContentType::TXT,
    }
  end

  before do
    @result_container = start_test_container("Container name")
    @test_case = start_test_case(name: "Test case", full_name: "Full name")
  end

  it "adds attachment to fixture" do
    expect(file_writer).to receive(:write_attachment).with("string attachment", duck_type(:name, :source, :type))

    fixture = lifecycle.start_prepare_fixture(Allure::FixtureResult.new(name: "Prepare fixture"))
    lifecycle.add_attachment(**attach_opts)
    attachment = fixture.attachments.last

    aggregate_failures "Attachment should be added" do
      expect(attachment.name).to eq("Test Attachment")
      expect(attachment.type).to eq(Allure::ContentType::TXT)
    end
  end

  it "adds attachment to step" do
    expect(file_writer).to receive(:write_attachment).with("string attachment", duck_type(:name, :source, :type))

    test_step = start_test_step(name: "Step name", descrption: "step description")
    lifecycle.add_attachment(**attach_opts)
    attachment = test_step.attachments.last

    aggregate_failures "Attachment should be added" do
      expect(attachment.name).to eq("Test Attachment")
      expect(attachment.type).to eq(Allure::ContentType::TXT)
    end
  end

  it "adds attachment to test" do
    expect(file_writer).to receive(:write_attachment).with("string attachment", duck_type(:name, :source, :type))

    lifecycle.add_attachment(**attach_opts)
    attachment = @test_case.attachments.last

    aggregate_failures "Attachment should be added" do
      expect(attachment.name).to eq("Test Attachment")
      expect(attachment.type).to eq(Allure::ContentType::TXT)
    end
  end

  it "adds file attachment to test" do
    expect(file_writer).to receive(:write_attachment).with(kind_of(File), duck_type(:name, :source, :type))

    lifecycle.add_attachment(
      name: "Test xlsx attachment",
      source: File.new(File.join(Dir.pwd, "spec", "fixtures", "blank.xlsx")),
      type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    )
    attachment = @test_case.attachments.last

    aggregate_failures "Attachment should be added" do
      expect(attachment.name).to eq("Test xlsx attachment")
      expect(attachment.type).to eq("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
      expect(attachment.source).to include(".xlsx")
    end
  end

  it "adds attachment to test explicitly" do
    expect(file_writer).to receive(:write_attachment).with("string attachment", duck_type(:name, :source, :type))

    test_step = start_test_step(name: "Step name", descrption: "step description")
    lifecycle.add_attachment(**attach_opts, test_case: true)
    attachment = @test_case.attachments.last

    aggregate_failures "Attachment should be added" do
      expect(attachment.name).to eq("Test Attachment")
      expect(attachment.type).to eq(Allure::ContentType::TXT)
      expect(test_step.attachments).to be_empty
    end
  end

  it "logs no running test case error" do
    allow(file_writer).to receive(:write_test_result)

    expect(logger).to receive(:error).with(/no test, step or fixture is running/)

    lifecycle.stop_test_case
    lifecycle.add_attachment(**attach_opts)
  end

  it "logs incorrect mime type error" do
    expect(logger).to receive(:error).with(/unrecognized mime type: nonsence/)

    lifecycle.add_attachment(
      name: "Test Attachment",
      source: "string attachment",
      type: "nonsence",
    )
  end
end
