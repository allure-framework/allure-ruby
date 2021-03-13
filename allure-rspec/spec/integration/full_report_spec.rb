# frozen_string_literal: true

describe "allure rspec" do
  include_context "rspec runner"

  let(:results_dir) { Allure.configuration.results_directory }

  it "generates allure json results files", integration: true do
    run_rspec(<<~RUBY)
      describe "integration test", epic: "testing", feature: "integration feature" do
        before(:each) do |e|
          e.step(name: "Before hook")
        end

        after(:each) do |e|
          e.step(name: "After hook")
        end

        it "spec", allure: "some_label" do |e|
          e.step(name: "test body")
        end
      end
    RUBY

    container = File.new(Dir["#{test_tmp_dir}/#{results_dir}/*container.json"].first)
    result = File.new(Dir["#{test_tmp_dir}/#{results_dir}/*result.json"].first)

    aggregate_failures "Results files should exist" do
      expect(File.exist?(container)).to be_truthy
      expect(File.exist?(result)).to be_truthy
    end

    container_json = JSON.parse(File.read(container), symbolize_names: true)
    result_json = JSON.parse(File.read(result), symbolize_names: true)
    aggregate_failures "Json results should contain valid data" do
      expect(container_json[:name]).to eq("integration test")
      expect(result_json[:name]).to eq("spec")
      expect(result_json[:description]).to eq("Location - #{test_tmp_dir}/spec/test_spec.rb:10")
      expect(result_json[:steps].size).to eq(3)
    end
  end
end
