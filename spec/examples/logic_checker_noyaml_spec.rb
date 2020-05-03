# frozen_string_literal: true

require './lib/rast'
require './examples/logic_checker'

rast LogicChecker do
  spec 'Logical AND - yaml-less' do
    variables({ left: [false, true], right: [false, true] })
    exclude('false[0] & true[1]')
    rules({ true => 'true[0] & true[1]' })

    execute { |left, right| subject.and(left, right) }
  end
end
