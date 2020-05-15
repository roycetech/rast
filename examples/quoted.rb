# frozen_string_literal: true

class Quoted

  def identify_sentence_type(sentence)
    return 'exclamation' if (sentence[/.*!/])

    return 'question' if (sentence[/.*\?/])

    'statement'
  end
end
