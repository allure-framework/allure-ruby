# frozen_string_literal: true

module Allure
  # General jsonable object implementation
  class JSONable
    # Return object hash represantation
    # @return [Hash]
    def to_hash
      json_attributes.each_with_object({}) do |attribute, map|
        key = camelcase(attribute)
        value = send(attribute) # fetch via reader for dynamically generated attributes
        map[key] = value unless value.nil?
      end
    end

    # Return object json string
    #
    # @param [Array] *options
    # @return [String]
    def to_json(*options)
      to_hash.to_json(*options)
    end

    # Object comparator
    # @param [JSONable] other
    # @return [Booelan]
    def ==(other)
      self.class == other.class && state == other.state
    end

    protected

    # Object state
    # @return [Array]
    def state
      json_attributes.map { |attribute| send(attribute) }
    end

    private

    # Covert string to camelcase
    # @param [String] str
    # @return [String]
    def camelcase(str)
      str = str.gsub(/(?:_+)([a-z])/) { Regexp.last_match(1).upcase }
      str.gsub(/(\A|\s)([A-Z])/) { Regexp.last_match(1) + Regexp.last_match(2).downcase }
    end

    # Json attribute names
    #
    # @return [Array<String>]
    def json_attributes
      @json_attributes ||= instance_variables.map { |attribute| attribute.to_s.delete_prefix("@") }
    end
  end
end
