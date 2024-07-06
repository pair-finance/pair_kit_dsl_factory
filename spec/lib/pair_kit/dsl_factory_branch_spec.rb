describe PairKit::DslFactory do
  describe '#branch' do
    context 'when two methods defined for the same builder' do
      let(:paren_factory) { described_class.new { configure_builder(:foo) { def hello; end } } }
      let(:child_factory) { paren_factory.branch { configure_builder(:foo) { def world; end } } }
      let(:parent_builder) { paren_factory.builders[:foo] }
      let(:child_builder) { child_factory.builders[:foo] }

      it { expect(paren_factory.default_builder).to eq :foo }
      it { expect(parent_builder).to have_instance_method(:hello) }
      it { expect(parent_builder).not_to have_instance_method(:world) }
      it { expect(child_factory.default_builder).to eq :foo }
      it { expect(child_builder).to have_instance_method(:hello) }
      it { expect(child_builder).to have_instance_method(:world) }
    end
  end
end
