require 'spec_helper'
require 'yacht/barnacle/event_collector'

describe Yacht::Barnacle::EventCollector do
  describe :report_duplicate do
    before :each do
      subject.push_key(:foo)
    end

    after :each do
      subject.pop_key
    end

    it 'keeps track of duplicate values' do
      subject.report_duplicate(:bar)

      subject.duplicates.should == {%w{foo} => :bar}
    end

    it 'reports on multiple levels of nesting' do
      subject.push_key(:bar)
      subject.push_key(:baz)

      subject.report_duplicate(:xyzzy)

      subject.duplicates.should == {%w{foo.bar.baz} => :xyzzy}
    end

    it 'does not report on keys that have been popped' do
      subject.push_key(:bar)
      subject.push_key(:baz)

      subject.pop_key

      subject.report_duplicate(:xyzzy)

      subject.duplicates.should == {%w{foo.bar} => :xyzzy}
    end

    context "with environments" do
      it "reports on the environment and parent environment" do
        subject.environments << "production"
        subject.environments << "prod_2"

        subject.report_duplicate(:bar)

        subject.duplicates.should == {%w{production prod_2 foo} => :bar}
      end
    end
  end
end
