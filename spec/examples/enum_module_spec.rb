# frozen_string_literal: true

require './examples/enum_module'
require 'rast'

rast EnumModule do
  spec '#enum_detected?' do
    variables({ params:
      [
        nil,
        'string',
        [],
        ['- a', '- b'],
        ['These are the options:', '- a', '- b']
      ] })

    rules('true' => [
            ['- a', '- b'],
            '|',
            ['These are the options:', '- a', '- b']
          ])

    pair('true' => false)

    execute { |param| subject.enum? param }
  end
end
