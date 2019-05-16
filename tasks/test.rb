# frozen_string_literal: true

ADAPTORS = %w[allure-ruby-commons allure-cucumber].freeze

# Run specific task for all adaptors
%w[test rubocop].each do |task_name|
  desc "Run #{task_name} for all projects"
  task task_name do
    errors = ADAPTORS.each_with_object([]) do |adaptor, a|
      puts "Executing #{task_name} for #{adaptor}"
      system("cd #{adaptor} && #{$PROGRAM_NAME} #{task_name}") || a << adaptor
    end
    raise Exception.new("Errors in #{errors.join(', ')}") unless errors.empty?
  end
end

# Run specific task for single adaptor
ADAPTORS.each do |adaptor|
  namespace adaptor do
    %w[test rubocop].each do |task_name|
      desc "Run #{task_name} for #{adaptor}"
      task task_name do
        system("cd #{adaptor} && #{$PROGRAM_NAME} #{task_name}")
      end
    end
  end
end
