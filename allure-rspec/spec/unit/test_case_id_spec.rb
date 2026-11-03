# frozen_string_literal: true

describe "RSpec test case identity" do
  include_context "allure mock"
  include_context "rspec runner"

  let(:results) { [] }
  let(:test_tmp_dir) { "tmp/test_case_identity" }
  let(:spec_source) do
    <<~RUBY
      RSpec.describe "Shared suite" do
        it("same description") {}
      end
    RUBY
  end

  before do
    allow(lifecycle).to receive(:start_test_case) { |result| results << result }
  end

  it "distinguishes identical descriptions in different files" do
    files = { "spec/a_spec.rb" => spec_source, "spec/b_spec.rb" => spec_source }
    expected = [
      Digest::MD5.hexdigest("tmp/test_case_identity/spec/a_spec.rb#Shared suite same description"),
      Digest::MD5.hexdigest("tmp/test_case_identity/spec/b_spec.rb#Shared suite same description")
    ]

    run_rspec(files)

    expect(results.map(&:test_case_id)).to contain_exactly(*expected)
  end

  it "keeps identity when source lines and example placement change" do
    run_rspec("spec/test_spec.rb" => spec_source)
    original = results.first
    moved_source = <<~RUBY


      RSpec.describe "Shared suite" do
        it("another example") {}
        it("same description") {}
      end
    RUBY

    run_rspec("spec/test_spec.rb" => moved_source)
    moved = results.last

    expect(moved.test_case_id).to eq(original.test_case_id).and(
      eq(Digest::MD5.hexdigest("tmp/test_case_identity/spec/test_spec.rb#Shared suite same description"))
    )
  end

  it "uses the owning file for shared examples" do
    shared_source = <<~RUBY
      RSpec.shared_examples "shared" do
        it("same description") {}
      end
    RUBY
    consuming_source = <<~RUBY
      require_relative "shared.rb"

      RSpec.describe "Shared suite" do
        it_behaves_like "shared"
      end
    RUBY
    files = {
      "spec/shared.rb" => shared_source,
      "spec/a_spec.rb" => consuming_source,
      "spec/b_spec.rb" => consuming_source
    }
    expected = [
      Digest::MD5.hexdigest(
        "tmp/test_case_identity/spec/a_spec.rb#Shared suite behaves like shared same description"
      ),
      Digest::MD5.hexdigest(
        "tmp/test_case_identity/spec/b_spec.rb#Shared suite behaves like shared same description"
      )
    ]

    expect { run_rspec(files) }.not_to output.to_stderr

    expect(results.map(&:test_case_id)).to contain_exactly(*expected)
  end
end
