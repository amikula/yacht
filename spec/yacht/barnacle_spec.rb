require 'spec_helper'
require 'yacht/barnacle'

describe Yacht::Barnacle do
  describe :flatten_keys do
    it 'returns the same hash when there is no nesting' do
      subject.flatten_keys('foo' => 'bar').should == {'foo' => 'bar'}
    end

    it 'flattens keys on nested hashes' do
      subject.flatten_keys('foo' => 'bar', 'baz' => {'xyzzy' => 'thud', 'thud' => {'thud' => 'splat'}}).should == {'foo' => 'bar', 'baz.xyzzy' => 'thud', 'baz.thud.thud' => 'splat'}
    end
  end

  describe :find_keys_not_overridden do
    it 'returns keys that are not overridden at the top level' do
      subject.find_keys_not_overridden('default' => {'foo' => 'bar', 'baz' => 'xyzzy', 'thud' => 'splat'}, 'development' => {'baz' => 'xyzzy2'}, 'production' => {'thud' => 'splat2'}).should == ['foo']
    end

    it 'returns keys that are not overridden at deeper levels' do
      subject.find_keys_not_overridden('default' => {'foo' => {'bar' => 'baz', 'xyzzy' => 'thud', 'splat' => 'wirble'}}, 'development' => {'foo' => {'bar' => 'baz2'}}, 'production' => {'foo' => {'xyzzy' => 'thud'}}).should == ['foo.splat']
    end
  end
end
