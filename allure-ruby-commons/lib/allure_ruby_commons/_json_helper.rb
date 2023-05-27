# frozen_string_literal: true

module Allure
  # Json helper methods
  #
  # @!method dump_json(obj)
  #   Dump object to json using Oj or JSON
  #   @param [Hash] obj
  #   @return [String]
  # @!method load_json(json)
  #   Load json from file using Oj or JSON
  #   @param [String] json
  #   @return [Hash]
  # @!method json_parse_error
  #   Json parse error class
  #   @return [Class]
  module JsonHelper
    # @return [Hash] Oj json options
    OJ_OPTIONS = { mode: :custom, use_to_hash: true, ascii_only: true }.freeze

    begin
      require "oj"

      define_method(:dump_json) do |obj|
        Oj.dump(obj, OJ_OPTIONS)
      end

      define_method(:load_json) do |json|
        Oj.load_file(json, symbol_keys: true)
      rescue Oj::ParseError
        nil
      end
    rescue LoadError
      define_method(:dump_json) do |obj|
        JSON.dump(obj)
      end

      define_method(:load_json) do |json|
        JSON.parse(File.read(json), symbolize_names: true)
      rescue JSON::ParserError
        nil
      end
    end
  end
end
