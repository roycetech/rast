# frozen_string_literal: true

require './lib/rast'
require './examples/factory_example'

rast FactoryExample do
  spec '#person_name' do
    prepare do |service_type|
      subject.instance_variable_set(:@person, build(service_type.to_sym))
    end

    execute { subject.person_name }
  end
end
