# DSL Factory 

This gem helps to build custom DSL. More documentation coming later.

---
**NOTE**

More documentation coming soon.

---


## Example

This example show how to build simple JSON Schema DSL.

### Step 1: Define your DSL parts as modules  

```ruby
module SchemaConcernDsl
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

module SchemaDsl
  include SchemaConcernDsl

  def _schema
    subject
  end
end

module StructDsl
  def prop(name, &block)
    name = name.to_sym
    subject[:properties][name] = {}

    build(:property, subject, name: name, &block)
  end
end

module ArrayDsl
  include SchemaConcernDsl

  def item(&block)
    build(:schema, subject[:item], &block)
  end

  def _schema
    subject[:item]
  end
end

module PropertyDsl
  include SchemaConcernDsl

  def required
    (subject[:required] ||= []) << options[:name]
  end

  private

  def _schema
    subject[:properties][options[:name]]
  end
end
```

### Step 2: Configure your factory

```ruby
class ApplicationModel < ActiveRecord::Model
  JSON_SCHEMA_BUILDER = DslFactory.new do
    configure_builder(:schema) { include SchemaDsl }
    configure_builder(:struct) { include StructDsl }
    configure_builder(:array) { include ArrayDsl }
    configure_builder(:property) { include PropertyDsl }
  end
  
  class_attribute :json_schema 
  
  def self.draw_schema(&block)
    self.json_schema = {}
    JSON_SCHEMA_BUILDER.build(json_schema).struct(&block)
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


