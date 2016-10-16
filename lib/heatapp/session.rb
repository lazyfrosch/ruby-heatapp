require 'heatapp'
require 'heatapp/auth_store'

require 'securerandom'

module Heatapp
  # Provides tooling to persist session credentials, login and out, and sign a request for the API
  class Session
    attr_reader :store

    def initialize
      @store = Heatapp::AuthStore.new
    end

    def load(readable)
      if readable.respond_to?(:read)
        @store.load(readable)
      else
        File.open(readable, 'r') do |io|
          @store.load(io)
        end
      end
    end

    def save(writable)
      if writable.respond_to?(:write)
        @store.save(writable)
      else
        File.open(writable, 'w') do |io|
          @store.save(io)
        end
      end
    end

    def udid
      udid = @store.get(:udid)
      unless udid
        # generate a random id
        udid = SecureRandom.uuid
        @store.set(:udid, udid)
        udid
      end
      udid
    end

    def udid=(udid)
      @store.set(:udid, udid)
    end

    def devicetoken
      devicetoken = @store.get(:devicetoken)
      raise 'devicetoken not stored!' unless devicetoken
      devicetoken
    end

    def devicetoken=(devicetoken)
      @store.set(:devicetoken, devicetoken)
    end

    def reqcount
      @store.get(:reqcount)
    end

    def reqcount_next
      c = reqcount
      c = 0 unless c
      c += 1
      self.reqcount = c
      c
    end

    def reqcount=(reqcount)
      @store.set(:reqcount, reqcount)
    end

    def valid?
      !(@store.get(:devicetoken).nil? || @store.get(:reqcount).nil? || @store.get(:udid).nil?)
    end
  end
end
