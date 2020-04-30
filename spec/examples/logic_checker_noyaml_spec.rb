# frozen_string_literal: true

require './lib/rast'
require './lib/rast/converters/bool_converter'
require './examples/logic_checker'

rast LogicChecker do
  spec 'Logical AND - yaml-less' do
    variables({ left: [false, true], right: [false, true] })
    exclude('false[0] & true[1]')
    rules({ true => 'true[0] & true[1]' })
    pair({ true => false })

    execute { |left, right| subject.and(left, right) }
  end
end
