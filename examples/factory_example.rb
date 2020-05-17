# frozen_string_literal: true

# Sample module
module FactoryExample
  def person_name
    return @person.alias_name if @person.alias_name
    return @person.last_name if @person.last_name

    @person.first_name
  end
end
