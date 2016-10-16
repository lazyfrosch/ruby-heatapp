require 'spec_helper'

require 'heatapp/auth_store'

describe Heatapp::AuthStore do
  before do
    @store = Heatapp::AuthStore.new
    @store.set('test', 123)
  end

  it 'has some data' do
    expect(@store.data).to eq({'test' => 123})
  end

  describe '.set' do
    before do
      @store.set('test2', 456)
    end

    context 'a value' do
      it 'should have set the value' do
        expect(@store.data['test2']).to eq(456)
      end
    end
  end

  describe '.get' do
    context 'a value' do
      it 'return the value' do
        expect(@store.get('test')).to eq(123)
      end
    end
  end

  describe '.delete' do
    context 'a value' do
      before do
        @store.delete('test')
      end

      it 'should have removed the key' do
        expect(@store.get('test')).to eq(nil)
      end
    end
  end

  describe '.reset' do
    context 'reset' do
      before do
        @store.reset
      end

      it 'should be empty' do
        expect(@store.data).to eq({})
      end
    end
  end

  describe '.save' do
    context 'save to file' do
      before do
        @test_file = Tempfile.new('rspec_authstore')
        @store.delete('test')
        @store.set('testvalue', 'verycomplex')
        @store.save(@test_file)
      end

      it 'file should contain YAML data' do
        @test_file.rewind
        expect(@test_file.read).to eq(YAML.dump(@store.data))
      end
    end
  end

  describe '.load' do
    context 'from file' do
      before do
        @test_file = Tempfile.new('rspec_authstore')
        @test_file.write("---\ntestvalue: othervalue")
        @store.load(@test_file)
      end

      it 'should only contain saved data' do
        expect(@store.get('test')).to eq(nil)
        expect(@store.get('testvalue')).to eq('othervalue')
      end
    end
  end
end
