# frozen_string_literal: true

require './lib/rast'
require './examples/factory_example'

rast FactoryExample do
  spec '#phone_plan_name' do
    prepare { |service_type| subject.instance_variable_set(:@phone, build(service_type.to_sym)) }
    execute { subject.phone_plan_name }
  end
end
