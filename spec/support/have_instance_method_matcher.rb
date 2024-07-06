RSpec::Matchers.define :have_instance_method do |name|
  match do |clz|
    clz.method_defined?(name)
  end
end
