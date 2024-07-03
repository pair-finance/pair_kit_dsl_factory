# DSL Factory 

This gem helps to build custom DSL. More documentation coming later.

---
**NOTE**

More documentation coming soon.

---

## Usage 
   
In your gemfile 

```ruby

gem 'pair-kit-dsl-factory'

```

In your code 

```ruby

require 'pair_kit/dsl_factory'

```


## Example

This example show how to build simple JSON Schema DSL.

### Step 1: Define your DSL parts as modules  

```ruby
module SchemaDsl
  def struct(&block)
    _schema[:type] = :object
    _schema[:properties] = {}
    _schema[:required] = []

    build(:struct, _schema, &block)
  end

  def array(&block)
    _schema[:type] = :array
    _schema[:item] ||= {}

    build(:array, _schema, &block)
  end

  def number
    _schema[:type] = :number
  end

  def string
    _schema[:type] = :string
  end
end

```

### Step 2: Configure your factory

```ruby
class ApplicationModel < ActiveRecord::Model
  JSON_SCHEMA_BUILDER = DslFactory.new do
    configure_builder(:schema, SchemaDsl) do
      private
      
      def _schema
        @subject
      end
    end
    
    configure_builder(:struct, SchemaDsl) do
      def prop(name, &block)
        name = name.to_sym
        @subject[:properties][name] = {}

        @dsl.(@subject, builder: :property, name: name, &block)
      end
    end
    
    configure_builder(:array, SchemaDsl) do
      def item(&block)
        @dsl.(@subject[:item], builder: :schema &block)
      end

      private

      def _schema
        @subject[:item]
      end
    end
    
    configure_builder(:property, SchemaDsl) do
      def required
        (@subject[:required] ||= []) << @options[:name]
      end

      private

      def _schema
        @subject[:properties][@options[:name]]
      end
    end
  end
  
  class_attribute :json_schema 
  
  def self.draw_schema(&block)
    self.json_schema ||= {}
    JSON_SCHEMA_BUILDER.builder(json_schema).struct(&block)
  end
end

``` 

### Step 3: Use your DSL

```ruby
class User < ApplicationModel
  draw_schema do 
    prop(:first_name).required.string
    prop(:last_name).required.string
    prop(:balance).required.number
    prop(:tags).required.array.string
  end
end
```


