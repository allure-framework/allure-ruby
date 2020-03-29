# frozen_string_literal: true

class RspecRunner
  def initialize(tmp_dir)
    @stdout = StringIO.new
    @stderr = StringIO.new
    @tmp_dir = tmp_dir
  end

  def run(spec)
    setup(spec)

    Dir.chdir(tmp_dir) do
      RSpec::Core::Runner.run([spec_file, *args], @stdout, @stderr)
    end
  ensure
    write_file("#{tmp_dir}/rspec_output.txt", all_output)
  end

  private

  attr_reader :tmp_dir

  def all_output
    [@stdout.string, @stderr.string].reject(&:empty?).join("\n")
  end

  def setup(spec)
    FileUtils.rm_rf(tmp_dir)

    write_file("#{tmp_dir}/#{spec_file}", spec)
  end

  def write_file(path, content)
    FileUtils.mkdir_p(File.dirname(path))
    File.open(path, "w") { |file| file.write(content) }
  end

  def spec_file
    "spec/test_spec.rb"
  end

  def args
    %w[
      --no-color
      --format documentation
      --format AllureRspecFormatter
    ]
  end
end
