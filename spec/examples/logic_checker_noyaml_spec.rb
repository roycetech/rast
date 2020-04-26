# frozen_string_literal: true

require './lib/rast'
require './lib/rast/converters/bool_converter'
require './examples/logic_checker'

rast LogicChecker do
  spec 'Logical AND - yaml-less' do
    variables({ left: [false, true], right: [false, true] })

    exclude('false[0]&true[1]')

    converters do
      bool_converter = BoolConverter.new
      Array.new(2, bool_converter)
    end

    rules({ true => 'true[0]&true[1]' })
    pair({ true => false })

    execute do |left, right|
      result subject.and(left, right)
    end
  end
end
