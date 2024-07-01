require 'spec_helper'


describe PairKit::DslFactory do
  describe '#branch' do
    context 'when two methods defined for the same builder' do
      let(:paren_factory) { described_class.new { configure_builder(:foo) { def hello; end } } }
      let(:child_factory) { paren_factory.branch { configure_builder(:foo) { def world; end } } }
      let(:parent_builder) { paren_factory.build({}) }
      let(:child_builder) { child_factory.build({}) }

      it { expect(paren_factory.default_builder).to eq :foo }
      it { expect(parent_builder).to respond_to(:hello) }
      it { expect(parent_builder).not_to respond_to(:world) }
      it { expect(child_factory.default_builder).to eq :foo }
      it { expect(child_builder).to respond_to(:hello) }
      it { expect(child_builder).to respond_to(:world) }
    end
  end
end
