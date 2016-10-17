require 'heatapp'
require 'heatapp/crypt'
require 'heatapp/exceptions'

require 'rest-client'
require 'uri'
require 'json'

module Heatapp
  # API interface to the REST API of Heatapp
  class Api
    attr_reader :session

    attr_accessor :host

    attr_accessor :last_error

    def initialize(host, opts = {})
      opts.each { |k, v| instance_variable_set("@#{k}", v) }

      @session  = Heatapp::Session.new unless @session
      self.host = host
    end

    # Build a full URL for the host
    def url(path)
      URI::Generic.build(
        scheme: 'http',
        host:   host,
        path:   path
      ).to_s
    end

    # Set some default headers for the API
    def default_headers(headers = {})
      headers           = {} unless headers
      headers['Accept'] = 'application/json' unless headers['Accept']
      headers
    end

    # Run a POST request against the API
    #
    # Accepts a block to handle the response.
    def post(args, &block)
      raise 'You should not set url, but path' if args[:url]

      args[:method] = :post
      args[:url]    = url(args[:path])
      args.delete(:path)
      args[:headers] = default_headers(args[:headers])

      RestClient::Request.execute(args, &block)
    end

    # Run a authenticated POST against the API
    #
    # Accepts a block to handle the response.
    def post_authenticated(args, &block)
      data           = args[:payload] || {}
      args[:payload] = Crypt.sign_request(
        data, session.udid, session.userid, session.devicetoken, session.reqcount_next
      )

      post(args, &block)
    end

    # Check if the user is actually logged in
    def logged_in?
      return false unless @session.valid?

      post_authenticated(path: '/api/systemstate') do |response|
        raise NotAuthenticatedError, "HTTP status #{response.code}: #{response.body[1..20]}" if response.code != 200

        data = parse_response(response)
        raise LoginFailedError, "Not logged in: #{data['message']}" unless data['success'].equal?(true)

        true
      end
    rescue LoginFailedError, NotAuthenticatedError => e
      @last_error = e
      false
    end

    # Login using challenge-response mechanism
    def login(username, password, device_name = 'Heatapp for Ruby')
      challenge = request_challenge
      data      = request_response_to_challenge(username, password, device_name, challenge)

      @session.devicetoken = data[:devicetoken]
      @session.userid      = data[:userid]
      @session.reqcount    = nil

      @session.valid?
    rescue LoginFailedError => e
      @last_error = e
      false
    end

    protected

    # check for HTTP code and parse JSON from body
    def parse_response(response)
      raise UnexpectedResponseError, 'status not 200' unless response.code == 200
      JSON.parse(response.body)
    rescue JSON::ParserError => e
      raise UnexpectedResponseError, "JSON error: #{e.message}"
    end

    # request a challenge
    def request_challenge
      post(path: '/api/user/token/challenge', payload: { udid: @session.udid }) do |response|
        challenge = parse_response(response)['devicetoken']
        raise UnexpectedResponseError, 'Does not contain devicetoken' unless challenge
        challenge
      end
    end

    # sent a response to the challenge
    def request_response_to_challenge(username, password, device_name, challenge)
      response_payload = {
        login:      username,
        devicename: device_name,
        token:      challenge,
        hashed:     Crypt.hash_auth_token(password, challenge),
        udid:       session.udid
      }

      post(path: '/api/user/token/response', payload: response_payload) do |response, json = parse_response(response)|
        raise LoginFailedError, "Login failed: #{json['message']}" unless json['success']
        unless json['devicetoken_encrypted'] && json['userid']
          raise UnexpectedResponseError, 'Does not contain devicetoken_encrypted or userid'
        end

        { devicetoken: Crypt.decrypt_devicetoken(json['devicetoken_encrypted'], password), userid: json['userid'] }
      end
    end
  end
end
