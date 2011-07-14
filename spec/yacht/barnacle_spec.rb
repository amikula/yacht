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

  describe :report_override_values do
    it 'indicates the number of times each key has been overridden to each value' do
      config_hash = YAML.load <<-EOF
      production:
        foo: bar
        baz: xyzzy
      development:
        foo: thud
        baz: xyzzy
      integration:
        foo: splat
        baz: wirble
      EOF

      subject.report_override_values(config_hash).should == {'foo' => {'bar' => 1, 'thud' => 1, 'splat' => 1}, 'baz' => {'xyzzy' => 2, 'wirble' => 1}}
    end

    it 'ignores values in the default environment' do
      config_hash = YAML.load <<-EOF
      default:
        foo: bar
      production:
        foo: bar
        baz: xyzzy
      EOF

      subject.report_override_values(config_hash).should == {'foo' => {'bar' => 1}, 'baz' => {'xyzzy' => 1}}
    end

    it 'reports on nested keys by flattening them' do
      config_hash = YAML.load <<-EOF
      production:
        foo:
          bar:
            baz: xyzzy
            thud: splat
      development:
        foo:
          bar:
            baz: xyzzy
            thud: splat2
      EOF

      subject.report_override_values(config_hash).should == {'foo.bar.baz' => {'xyzzy' => 2}, 'foo.bar.thud' => {'splat' => 1, 'splat2' => 1}}
    end
  end
end
