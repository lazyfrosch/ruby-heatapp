require 'spec_helper'

require 'heatapp/session'

describe Heatapp::Session do
  it 'has a store' do
    expect(subject.store).to be_a(Heatapp::AuthStore)
  end

  describe '.udid' do
    it 'should generate a UUID and store it' do
      expect(subject.udid).to match(/^[a-f0-9\-]+$/)
      expect(subject.store.get(:udid)).to eq(subject.udid)
    end
  end

  describe '.udid=' do
    before do
      subject.udid = 'TEST'
    end

    it 'should save the value to the store' do
      expect(subject.store.get(:udid)).to eq('TEST')
    end
  end

  describe '.devicetoken' do
    it 'raise an error unless previously set' do
      expect { subject.devicetoken }.to raise_error(/devicetoken not stored/)
    end
  end

  describe '.devicetoken=' do
    before do
      subject.devicetoken = 'abc123456'
    end

    it 'should save token to store' do
      expect(subject.store.get(:devicetoken)).to eq('abc123456')
    end
    it '.devicetoken should return that value' do
      expect(subject.devicetoken).to eq('abc123456')
    end
  end

  describe '.reqcount' do
    it 'should be nil by start' do
      expect(subject.reqcount).to be_nil
    end
  end

  describe '.reqcount_next' do
    before do
      subject.reqcount_next
    end
    it 'should start with 1' do
      expect(subject.reqcount).to eq(1)
    end
    it 'should save the value' do
      expect(subject.store.get(:reqcount)).to eq(1)
      expect(subject.reqcount).to eq(1)
    end
    it 'and increment and save on every call' do
      expect(subject.reqcount_next).to eq(2)
      expect(subject.reqcount).to eq(2)
      expect(subject.reqcount_next).to eq(3)
      expect(subject.reqcount).to eq(3)
    end
  end

  describe '.reqcount=' do
    before do
      subject.reqcount = 567
    end

    it 'should have saved a new value' do
      expect(subject.reqcount).to eq(567)
    end
  end

  describe '.valid?' do
    it 'should not be valid by default' do
      expect(subject.valid?).to eq(false)
    end

    it 'should be valid after setting values' do
      subject.devicetoken = 'TEST'
      subject.udid
      subject.reqcount_next

      expect(subject.valid?).to be(true)
    end
  end
end
