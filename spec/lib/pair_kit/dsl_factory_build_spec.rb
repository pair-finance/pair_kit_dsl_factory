describe PairKit::DslFactory do
  describe '#build' do
    let(:factory) { described_class.new }

    describe 'main behaviour' do
      let(:schema_concern_dsl) {
        Module.new do
          def struct(&block)
            _schema[:type] = :object
            _schema[:properties] = {}
            _schema[:required] = []

            @dsl.(_schema, builder: :struct, &block)
          end

          def array(&block)
            _schema[:type] = :array
            _schema[:items] ||= {}

            @dsl.(_schema, builder: :array, &block)
          end

          def number
            _schema[:type] = :number
          end

          def string
            _schema[:type] = :string
          end
        end
      }

      before do
        factory.configure_builder(:schema, schema_concern_dsl) do
          private

          def _schema
            @subject
          end
        end

        factory.configure_builder(:struct, schema_concern_dsl) do
          def prop(name, &block)
            name = name.to_sym
            @subject[:properties][name] = {}

            @dsl.(@subject, builder: :property, name: name, &block)
          end
        end

        factory.configure_builder(:array, schema_concern_dsl) do
          def items(&block)
            build(@subject[:items], &block)
          end

          private

          def _schema
            @subject[:items]
          end
        end

        factory.configure_builder(:property, schema_concern_dsl) do
          def required
            (@subject[:required] ||= []) << @options[:name]
          end

          private

          def _schema
            @subject[:properties][@options[:name]]
          end
        end
      end

      context 'when simple struct defined' do
        subject do
          factory.build({}) do
            struct do
              prop(:first_name).required.string
              prop(:last_name).required.string
              prop(:balance).required.number
            end
          end
        end

        let(:result) do
          {
            type: :object,
            properties: {
              first_name: { type: :string },
              last_name: { type: :string },
              balance: { type: :number }
            },
            required: %i[first_name last_name balance]
          }
        end

        it { is_expected.to eq(result) }
      end

      context 'when struct in array defined' do

        subject do
          factory.build({}) do
            array.struct do
              prop(:first_name).required.string
              prop(:last_name).required.string
              prop(:balance).required.number
            end
          end
        end

        let(:result) do
          {
            type: :array,
            items: {
              type: :object,
              properties: {
                first_name: { type: :string },
                last_name: { type: :string },
                balance: { type: :number }
              },
              required: %i[first_name last_name balance]
            }
          }
        end

        it { is_expected.to eq(result) }
      end

      context 'when struct with array of string defined' do
        subject { factory.build({}) { struct { prop(:tags).required.array.string } } }

        let(:result) do
          {
            type: :object,
            properties: {
              tags: {
                type: :array,
                items: {
                  type: :string,
                }
              }
            },
            required: %i[tags]
          }
        end

        it { is_expected.to eq(result) }
      end
    end

    describe 'behaviour with context' do
      before do
        factory.configure_builder :foo do
          def hello
            @context.hello(@options[:builder])
            @dsl.call(@subject, builder: :moo)
          end
        end

        factory.configure_builder :moo do
          def world
            @context.world(@options[:builder])
          end
        end
      end

      it 'passes a context to all builders' do
        context = double()

        expect(context).to receive(:hello).with(:foo)
        expect(context).to receive(:world).with(:moo)

        factory.build({}, context) do
          hello.world
        end
      end
    end
  end
end
