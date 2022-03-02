# frozen_string_literal: true

require "oj"

module Allure
  # General jsonable object implementation
  class JSONable
    # Return object hash represantation
    # @return [Hash]
    def to_hash
      instance_variables.each_with_object({}) do |var, map|
        key = camelcase(var.to_s.delete_prefix("@"))
        value = instance_variable_get(var)
        map[key] = value unless value.nil?
      end
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
      instance_variables.map { |var| instance_variable_get(var) }
    end

    private

    # Covert string to camelcase
    # @param [String] str
    # @return [String]
    def camelcase(str)
      str = str.gsub(/(?:_+)([a-z])/) { Regexp.last_match(1).upcase }
      str.gsub(/(\A|\s)([A-Z])/) { Regexp.last_match(1) + Regexp.last_match(2).downcase }
    end
  end
end
