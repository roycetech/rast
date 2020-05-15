# frozen_string_literal: true

require './examples/quiz_module'
require 'rast'

rast QuizModule do
  spec '#quiz_multi_choice?' do
    execute do |param|
      subject.quiz_multi_choice? eval(param)
    end
  end
end
