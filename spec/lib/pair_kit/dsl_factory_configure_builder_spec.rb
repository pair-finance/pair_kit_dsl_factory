module World
  def world; end
end

module World2
  def world2; end
end

describe PairKit::DslFactory do
  describe '#configure_builder' do
    subject { factory.({}) }

    let(:factory) { described_class.new }

    context 'when builder method defined' do
      before { factory.configure_builder(:foo) { def hello; end } }

      it { is_expected.to respond_to(:hello) }
    end

    context 'when two builder methods defined together' do
      before do
        factory.configure_builder(:foo) do
          def hello; end
          def hello2; end
        end
      end

      it { is_expected.to respond_to(:hello) }
      it { is_expected.to respond_to(:hello2) }
    end

    context 'when two builder methods defined consecutively' do
      before do
        factory.configure_builder(:foo) { def hello; end }
        factory.configure_builder(:foo) { def hello2; end }
      end

      it { is_expected.to respond_to(:hello) }
      it { is_expected.to respond_to(:hello2) }
    end

    context 'when a module included' do
      before { factory.configure_builder(:foo) { include World } }

      it { is_expected.to respond_to(:world) }
    end

    context 'when two modules included together' do
      before do
        factory.configure_builder(:foo) do
          include World
          include World2
        end
      end

      it { is_expected.to respond_to(:world) }
      it { is_expected.to respond_to(:world2) }
    end

    context 'when two modules included consecutively' do
      before do
        factory.configure_builder(:foo) { include World }
        factory.configure_builder(:foo) { include World2 }
      end

      it { is_expected.to respond_to(:world) }
      it { is_expected.to respond_to(:world2) }
    end

    context 'when two modules passed as params' do
      before do
        factory.configure_builder(:foo, World, World2)
      end

      it { is_expected.to respond_to(:world) }
      it { is_expected.to respond_to(:world2) }
    end

    context 'when one module passed, another included and method defined' do
      before do
        factory.configure_builder(:foo, World) do
          include World2
          def hello; end
        end
      end

      it { is_expected.to respond_to(:world) }
      it { is_expected.to respond_to(:world2) }
      it { is_expected.to respond_to(:hello) }
    end

    context 'when two modules passed in a deep array' do
      before do
        factory.configure_builder(:foo, [World, [World2]])
      end

      it { is_expected.to respond_to(:world) }
      it { is_expected.to respond_to(:world2) }
    end
  end
end
