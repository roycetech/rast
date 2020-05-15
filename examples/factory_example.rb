# frozen_string_literal: true

# Sample module
module FactoryExample
  def phone_plan_name
    return @phone.third_name if @phone.third_name
    return @phone.second_name if @phone.second_name

    @phone.first_name
  end
end
