# frozen_string_literal: true

RSpec.describe "adding methods" do # rubocop:disable RSpec/DescribeClass
  let(:klass) do
    Class.new do
      extend MemoWise
      def self.no_args; end
      def no_args; end
    end
  end

  context "when class extends MemoWise" do
    subject { klass.memo_wise(:no_args) }

    let(:expected_public_instance_methods) do
      %i[
        preset_memo_wise
        reset_memo_wise
        _memo_wise
      ].to_set
    end

    let(:expected_public_class_methods) do
      %i[
        _memo_wise
        freeze
        preset_memo_wise
        reset_memo_wise
      ].to_set
    end

    it "adds expected public *instance* methods only" do
      expect { subject }.
        to change { klass.public_instance_methods.to_set }.
        by(expected_public_instance_methods)
    end

    it "adds no private *instance* methods" do
      expect { subject }.
        not_to change { klass.private_instance_methods.to_set }
    end

    it "adds expected public *class* methods only" do
      expect { klass.memo_wise(self: :no_args) }.
        to change { klass.singleton_methods.to_set }.
        by(expected_public_class_methods)
    end

    it "adds no private *class* methods" do
      expect { subject }.
        not_to change { klass.singleton_class.private_methods.to_set }
    end

    # These test cases would fail due to a JRuby bug
    # Skipping to make build pass until the bug is fixed
    unless RUBY_PLATFORM == "java"
      context "when a class method is memoized" do
        subject do
          klass.send(:extend, MemoWise)
          klass.send(:memo_wise, self: :example)
        end

        let(:klass) do
          Class.new do
            def self.example; end
          end
        end

        let(:expected_public_class_methods) { super() << :inherited }

        it "adds expected public *instance* methods only" do
          expect(klass.singleton_methods).to include(*klass.singleton_methods)
          subject
        end
      end
    end
  end
end
