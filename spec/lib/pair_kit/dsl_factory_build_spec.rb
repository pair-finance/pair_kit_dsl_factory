require 'spec_helper'

describe PairKit::DslFactory do
  describe '#build' do
    subject { schema }

    let(:factory) { described_class.new }
    let(:schema) { {} }

    let(:schema_concern_dsl) {
      Module.new do
        def struct(&block)
          _schema[:type] = :object
          _schema[:properties] = {}
          _schema[:required] = []

          build(_schema, builder: :struct, &block)
        end

        def array(&block)
          _schema[:type] = :array
          _schema[:item] ||= {}

          build(_schema, builder: :array, &block)
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
          subject
        end
      end

      factory.configure_builder(:struct, schema_concern_dsl) do
        def prop(name, &block)
          name = name.to_sym
          subject[:properties][name] = {}

          build(subject, builder: :property, name: name, &block)
        end
      end

      factory.configure_builder(:array, schema_concern_dsl) do
        def item(&block)
          build(subject[:item], &block)
        end

        private

        def _schema
          subject[:item]
        end
      end

      factory.configure_builder(:property, schema_concern_dsl) do
        def required
          (subject[:required] ||= []) << options[:name]
        end

        private

        def _schema
          subject[:properties][options[:name]]
        end
      end
    end

    context 'when simple struct defined' do
      before do
        factory.build(schema) do
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
      before do
        factory.build(schema).array.struct do
          prop(:first_name).required.string
          prop(:last_name).required.string
          prop(:balance).required.number
        end
      end

      let(:result) do
        {
          type: :array,
          item: {
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
      before do
        factory.build(schema).struct do
          prop(:tags).required.array.string
        end
      end

      let(:result) do
        {
          type: :object,
          properties: {
            tags: {
              type: :array,
              item: {
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
end
