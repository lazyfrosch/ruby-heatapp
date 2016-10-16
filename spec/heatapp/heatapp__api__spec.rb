require 'spec_helper'

require 'heatapp/api'
require 'heatapp/session'

describe Heatapp::Api do
  before do
    stub_request(:post, "http://#{subject.host}/api/user/token/challenge")
      .with(body: "udid=#{subject.session.udid}")
      .to_return(
        status: 200,
        body:   '{"success":true,"message":"","loginRejected":false,'\
                  '"devicetoken":"e5a683aeea7788cbeb2b40fb0d4924c9","language":"en","performance":0.021}'
      )

    stub_request(:post, "http://#{subject.host}/api/user/token/response")
      .with(body: "login=username&devicename=Test&token=e5a683aeea7788cbeb2b40fb0d4924c9&"\
                    "hashed=7c251b46cd9a69cb12cecf4407414547&udid=#{subject.session.udid}")
      .to_return(
        status: 200,
        body:   '{"success":true,"message":"","loginRejected":false,'\
                  '"devicetoken_encrypted":"33ZTOuu10ZAJLd70IaP+phKyuPkoZdMmh6GSLv5mqHlSjthIIHqbLqjLOh3F7kNs",'\
                  '"userid":1,"language":"en","performance":0.066}'
      )

    stub_request(:post, "http://#{subject.host}/api/user/token/response")
      .with(body: "login=username&devicename=Test&token=5105eb3fb76282a5255fb31dd5af6968&"\
                    "hashed=c7fb3e56ae8bc40b48506b46924962dd&udid=#{subject.session.udid}")
      .to_return(
        status: 200,
        body:   '{"success":false,"message":"This token doesn\'t exist.",'\
                  '"loginRejected":false,"language":"en","performance":0.01}'
      )
  end

  subject do
    Heatapp::Api.new('heatapp.localdomain')
  end

  describe '.initialize' do
    it 'should have a session handler' do
      expect(subject.session).to be_a(Heatapp::Session)
    end

    it 'should let you set a custom session handler' do
      session_test = Heatapp::Session.new
      expect(Heatapp::Api.new('testhost.localdomain', session: session_test).session).to be(session_test)
    end
  end

  describe '.url' do
    it 'should build an URL' do
      expect(subject.url('/test/url')).to eq("http://#{subject.host}/test/url")
    end
  end

  describe '.post' do
    it 'should sent a proper POST request' do
      stub_request(:post, "http://#{subject.host}/test/url")
        .with(headers: {Accept: 'application/json'})

      expect { |b| subject.post(path: '/test/url', &b) }
        .to yield_with_args(RestClient::Response, RestClient::Request, Net::HTTPOK)
    end
  end

  describe '.post_authenticated' do
    # Tested with logged_in?
  end

  describe '.logged_in?' do
    before do
      subject.session.devicetoken = 'f12a53d48420bd688b805e1e2181df63'
      subject.session.userid = 1
      subject.session.udid = 'b5eb3d7b-3ae1-445a-ac39-790bd8f1b8ad'
      subject.session.reqcount = 122
    end

    it 'should return true with a proper response' do
      stub_request(:post, "http://#{subject.host}/api/systemstate")
        .with(body: "udid=#{subject.session.udid}&userid=1&reqcount=123&"\
                      'request_signature=4f1b4d9040fe630f879ebd9bc715aa87')
        .to_return(status: 200, body: '{"success": true}')

      expect(subject.logged_in?).to eq(true)
    end

    it 'should return false on a non 200 response' do
      stub_request(:post, "http://#{subject.host}/api/systemstate").to_return(status: 302)
      expect(subject.logged_in?).to eq(false)
    end

    it 'should return false on a non successful response' do
      stub_request(:post, "http://#{subject.host}/api/systemstate")
        .to_return(
          status: 200,
          body:   '{"success":false,"message":"You have been logged out. Please log in again.",'\
                '"loginRejected":true,"product":"heatapp-server","language":"en","performance":0.01}'
        )

      expect(subject.logged_in?).to eq(false)
    end
  end

  describe '.login' do
    it 'should log you in and save state to session' do
      expect(subject.login('username', 'password', 'Test')).to eq(true)
      expect(subject.session.devicetoken).to eq('f12a53d48420bd688b805e1e2181df63')
      expect(subject.session.userid).to eq(1)
      expect(subject.session.reqcount).to eq(nil)
    end
  end

  describe '.parse_response' do
    it 'should parse JSON and return data' do
      response = RestClient::Response.new('{"success": true, "message": "Test"}')
      expect(subject.instance_eval { parse_response(response) }).to eq('success' => true, 'message' => 'Test')
    end

    it 'should raise UnexpectedResponseError on invalid JSON' do
      response = RestClient::Response.new('{"invalid",,}')
      expect { subject.instance_eval { parse_response(response) } }.to raise_error(Heatapp::UnexpectedResponseError)
    end
  end

  describe '.request_challenge' do
    it 'should make a challange request' do
      expect(subject.instance_eval { request_challenge }).to eq('e5a683aeea7788cbeb2b40fb0d4924c9')
    end
  end

  describe '.request_response_to_challenge' do
    it 'should fail when the token is unknown' do
      expect {
        subject.instance_eval do
          request_response_to_challenge('username', 'password', 'Test', '5105eb3fb76282a5255fb31dd5af6968')
        end
      }.to raise_error(Heatapp::LoginFailedError)
    end

    it 'when the request is successful' do
      expect(
        subject.instance_eval do
          request_response_to_challenge('username', 'password', 'Test', 'e5a683aeea7788cbeb2b40fb0d4924c9')
        end
      ).to eq(devicetoken: 'f12a53d48420bd688b805e1e2181df63', userid: 1)
    end
  end
end
