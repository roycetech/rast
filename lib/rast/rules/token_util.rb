# frozen_string_literal: true

#
module TokenUtil
  # /**
  #  * Returns value of 'n' if rule token ends with '[n]'. where 'n' is the
  #  * variable group index.
  #  *
  #  * @param string token to check for subscript.
  #  */
  def self.extract_subscript(token: '')
    return -1 if token.is_a? Array

    subscript = token[/\[(\d+)\]$/, 1]
    subscript.nil? ? -1 : subscript.to_i
  end
end
