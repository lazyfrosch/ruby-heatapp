require 'spec_helper'

require 'heatapp/crypt'

describe Heatapp::Crypt do
  subject do
    Heatapp::Crypt
  end

  before do
    @test_hash = {
      integer: 123,
      array:   %w(test foo bar),
      string:  'tester',
      float:   456.01
    }
  end

  describe '.hash_auth_token' do
    it 'should hash password and devicetoken' do
      expect(subject.hash_auth_token('devicetoken', 'password')).to eq('8cc6bbd13de2b7d177a90aaaf02c20d2')
    end
  end

  describe '.sign_request_string' do
    it 'should hash request_string and devicetoken' do
      expect(subject.sign_request_string('test=1|muh=2|bar=test|', 'devicetoken'))
        .to eq('83e93019af3011f2bef5225bb24f97df')
    end
  end

  describe '.array_to_list' do
    it 'should handle an empty array' do
      expect(subject.array_to_list([])).to eq('')
    end
    it 'should handle an array with a single entry' do
      expect(subject.array_to_list(['test'])).to eq('test')
    end
    it 'should handle other arrays' do
      expect(subject.array_to_list(%w(test foo bar))).to eq('[test,foo,bar]')
    end
  end

  describe '.build_data_string' do
    it 'should only accept a hash for data' do
      expect { subject.build_data_string([]) }.to raise_error(/has to be a Hash/)
    end

    it 'should handle an examples' do
      expect(subject.build_data_string(@test_hash))
        .to eq('array=[test,foo,bar]|float=456.01|integer=123|string=tester|')
    end
  end

  describe '.data_signature' do
    it 'should return a properly signature' do
      expect(subject.data_signature('devicetoken', @test_hash)).to eq('f12a53d48420bd688b805e1e2181df63')
    end
  end

  describe '.sign_request' do
    it 'should update the request hash' do
      # TODO: verify the result is correct
      expect(subject.sign_request(@test_hash, 'test_udid', 4, 'devicetoken', 1234))
        .to eq(
          @test_hash.merge(
            udid:              'test_udid',
            userid:            4,
            reqcount:          1234,
            request_signature: 'fc107661a70a60d7b22b98ecdb39c155'
          )
        )
    end
  end

  describe '.decrypt_devicetoken' do
    it 'should decrypt' do
      devicetoken_encrypted = '33ZTOuu10ZAJLd70IaP+phKyuPkoZdMmh6GSLv5mqHlSjthIIHqbLqjLOh3F7kNs'
      devicetoken = 'f12a53d48420bd688b805e1e2181df63'
      expect(subject.decrypt_devicetoken(devicetoken_encrypted, 'password')).to eq(devicetoken)
    end
  end

  # describe '.encrypt_devicetoken' do
  #   it 'should encrypt' do
  #     devicetoken_encrypted = '33ZTOuu10ZAJLd70IaP+phKyuPkoZdMmh6GSLv5mqHlSjthIIHqbLqjLOh3F7kNs'
  #     devicetoken = 'f12a53d48420bd688b805e1e2181df63'
  #     expect(subject.encrypt_devicetoken(devicetoken, 'password')).to eq(devicetoken_encrypted)
  #   end
  # end
end
