require 'heatapp'

require 'digest/md5'

module Heatapp
  # Providing crypto helpers to the gem
  #
  # most of the functions can be found in JavaScript code of the original web app
  #
  # NOTE: There are also functions with pbkdf2 instead of MD5 inside assets.min.js,
  # but they seem not to be used.
  #
  class Crypt
    # Hash the password with the challenge for login
    #
    # Derived from request.hashAuthenticationToken (oem.min.js)
    def self.hash_auth_token(password, devicetoken)
      Digest::MD5.hexdigest(password + devicetoken)
    end

    # Hash for a signed request
    #
    # Takes a serialized data_string from sign_request
    #
    # Derived from request.encodeRequestSignature (oem.min.js)
    def self.sign_request_string(data_string, devicetoken)
      Digest::MD5.hexdigest(data_string + devicetoken)
    end

    # Make a comma separated list form an array
    #
    # Example:
    #  'single_entry' or '[foo,bar,lol]'
    #
    # Part of request.getRequestSignature (assets.min.js)
    def self.array_to_list(array)
      if array.empty?
        ''
      elsif array.length < 2
        array[0]
      else
        "[#{array.join(',')}]"
      end
    end

    # Build a data_string from an Hash
    #
    # Output:
    #  'a=1|b=foo|c=[test,foo,bar]|'
    #
    # Part of request.getRequestSignature (assets.min.js)
    def self.build_data_string(data)
      raise 'data has to be a Hash' unless data.is_a?(Hash)
      data_string = ''
      data.keys.sort.each do |key, value = data[key]|
        value_s = value.is_a?(Array) ? array_to_list(value) : value.to_s
        data_string += "#{key}=#{value_s}|"
      end
      data_string
    end

    # Serialize data and return signature
    #
    # Derived from request.getRequestSignature (assets.min.js)
    def self.data_signature(devicetoken, data)
      sign_request_string(build_data_string(data), devicetoken)
    end

    # Update a request hash with authentication data and a signature
    #
    # Derived from request.makeRequestData (assets.min.js)
    def self.sign_request(data, udid, userid, devicetoken, reqcount)
      raise 'data has to be a Hash' unless data.is_a?(Hash)
      data[:udid] = udid
      data[:userid] = userid
      data[:reqcount] = reqcount
      data[:request_signature] = data_signature(devicetoken, data)
      data
    end
  end
end
