require 'spec_helper'

RSpec.describe Chainer do
  let(:result_object) { double('result object', failure?: false, value: true) }
  let(:service_object) { double('service object', call: result_object) }

  describe '#chain' do
    it 'always returns it\'s receiver' do
      expect(subject.chain { service_object.call }).to eq subject
    end
  end

  describe '#result' do
    let(:result_object2) { double('result object 2', failure?: false, value: false) }
    let(:service_object2) { double('service object 2', call: result_object2) }

    context 'when all the chanis are successful' do
      it 'returns the last chain\'s response' do
        expect(subject.chain { service_object.call }.
                       chain { service_object2.call }.
                       result).to eq result_object2
      end
    end

    context 'when some chain is failed' do
      let(:result_object) { double('result object', failure?: true, value: false) }

      it 'returns the last chain\'s response' do
        expect(subject.chain { service_object.call }.
                       chain { service_object2.call }.
                       result).to eq result_object
      end
    end
  end

  context 'yield control' do
    let(:to_proc) do
      proc do |block|
        block.define_singleton_method(:to_proc) do
          # Rspec-Expectations hack to inject the passed block's value to the inside of the method
          # https://github.com/rspec/rspec-expectations/blob/v3.1.0/lib/rspec/matchers/built_in/yield.rb#L39
          @used = true
          probe = self
          callback = @callback
          proc do |*args|
            probe.num_yields += 1
            probe.yielded_args << args
            callback.call(*args)
            RSpec::Mocks::Double.new(failure?: false, value: true)
          end
        end
      end
    end

    specify 'in the first #chain call it yields with nil' do
      expect do |block|
        to_proc.call(block)

        subject.chain(&block)
      end.to yield_with_args(nil)
    end

    specify 'in the subsequent #chain call it yields with the previous #chain call result' do
      expect do |block|
        to_proc.call(block)

        subject.chain(&block).chain(&block)
      end.to yield_successive_args(nil, true)
    end
  end

  it 'has a version number' do
    expect(Chainer::VERSION).to eq '0.1.0'
  end
end
