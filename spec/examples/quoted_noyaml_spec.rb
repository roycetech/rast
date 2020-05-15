# frozen_string_literal: true

require './lib/rast'
require './examples/quoted'

rast Quoted do
  spec '#identify_sentence_type' do
    rules({
      exclamation: ["Let's do it!"],
      question: ['Will this & you work?'],
      statement: ["Let's make a statement"]
    })

    execute { |statement| subject.identify_sentence_type(statement) }
  end
end
