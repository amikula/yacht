require 'spec_helper'

describe Yacht::HashHelper do
  subject { Yacht::HashHelper }

  describe :deep_merge do
    it "recursively merges hashes" do
      subject.deep_merge({:foo => {:bar => :baz}}, {:foo => {:xyzzy => :thud}}).should ==
        {:foo => {:bar => :baz, :xyzzy => :thud}}
    end

    context "with an event collector" do
      before :each do
        @event_collector = mock(:push_key => nil, :report_duplicate => nil, :pop_key => nil)
      end

      it "calls report_duplicate when a duplicate value is detected" do
        @event_collector.should_receive(:report_duplicate).with(:bar)

        subject.deep_merge({:foo => :bar}, {:foo => :bar}, @event_collector)
      end

      it "calls push_key when recursing downward" do
        @event_collector.should_receive(:push_key).with(:foo).ordered
        @event_collector.should_receive(:push_key).with(:bar).ordered

        subject.deep_merge({:foo => {:bar => :baz}}, {:foo => {:bar => :xyzzy}}, @event_collector)
      end

      it "calls pop_key when recursing downward" do
        @event_collector.should_receive(:pop_key).ordered
        @event_collector.should_receive(:pop_key).ordered

        subject.deep_merge({:foo => {:bar => :baz}}, {:foo => {:bar => :xyzzy}}, @event_collector)
      end
    end
  end
end
