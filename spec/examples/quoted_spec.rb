# frozen_string_literal: true

require './lib/rast'
require './examples/quoted'

rast Quoted do
  spec '#identify_sentence_type' do
    execute { |statement| subject.identify_sentence_type(statement) }
  end
end
