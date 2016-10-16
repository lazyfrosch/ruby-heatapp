require 'heatapp'
require 'yaml'

module Heatapp
  # Takes care of storing session data into any IO as YAML data
  class AuthStore
    attr_reader :data

    def initialize
      @data = {}
    end

    # Loads the stored data from a
    def load(readable)
      readable.rewind
      data = YAML.load(readable)
      raise "Unsupported Format #{data.class} parsed from #{readable}" unless data.is_a?(Hash)
      @data = data
    end

    def save(writable)
      writable.rewind
      YAML.dump(@data, writable)
    end

    def set(key, value)
      @data[key.to_s] = value
    end

    def delete(key)
      @data.delete(key.to_s)
    end

    def get(key)
      @data[key.to_s]
    end

    def reset
      @data = {}
    end
  end
end
