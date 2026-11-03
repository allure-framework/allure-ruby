# frozen_string_literal: true

class RspecRunner
  SPEC_FILE = "spec/test_spec.rb"

  def initialize(tmp_dir)
    @stdout = StringIO.new
    @stderr = StringIO.new
    @tmp_dir = tmp_dir
  end

  # @param [String, Hash<String, String>] spec source or relative paths mapped to source
  # Hash inputs run all supplied files in insertion order.
  def run(spec)
    files = spec.is_a?(Hash) ? spec : { SPEC_FILE => spec }
    spec_files = files.keys.select { |f| f.end_with?("_spec.rb") }

    setup(files)

    Dir.chdir(tmp_dir) do
      RSpec::Core::Runner.run([*spec_files, *args], @stdout, @stderr)
    end
  ensure
    write_file("#{tmp_dir}/rspec_output.txt", all_output)
  end

  private

  attr_reader :tmp_dir

  def all_output
    [@stdout.string, @stderr.string].reject(&:empty?).join("\n")
  end

  def setup(files)
    FileUtils.rm_rf(tmp_dir)

    files.each { |path, source| write_file("#{tmp_dir}/#{path}", source) }
  end

  def write_file(path, content)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
  end

  def args
    %w[
      --no-color
      --format documentation
      --format AllureRspecFormatter
    ]
  end
end
