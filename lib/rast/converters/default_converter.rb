# frozen_string_literal: true

# Converts string into boolean
class DefaultConverter
  def convert(object)
    return nil if object == 'nil'

    object
  end
end
