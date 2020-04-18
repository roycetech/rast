# frozen_string_literal: true

# Converts string into boolean
class BoolConverter
  def convert(string)
    return nil if string == 'nil'

    string == 'true'
  end
end
