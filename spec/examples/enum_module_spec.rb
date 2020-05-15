# frozen_string_literal: true

# combination of yaml and no yaml

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

    outcomes('true' => [
               ['- a', '- b'],
               '|',
               ['These are the options:', '- a', '- b']
             ])
    execute { |param| subject.enum? param }
  end

  spec '#ordered?' do
    variables({ params:
      [
        ['- apple', '- banana'],
        ['1. one', '2. two']
      ] })

    rules('true' => [['1. one', '2. two']])
    execute { |param| subject.ordered? param }
  end
end
