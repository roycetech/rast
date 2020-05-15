# frozen_string_literal: true

require './lib/rast'
require './lib/rast/rules/logic_helper'

# Provides logic evaluation functionalities.
rast LogicHelper do
  spec '#perform_logical, AND' do
    execute do |scenario, left_subscript, left, right_subscript, right|
      subject.perform_logical(
        scenario: scenario,
        left: { value: left, subscript: left_subscript },
        right: { value: right, subscript: right_subscript },
        operation: :and
      )
    end
  end

  spec '#perform_logical, OR' do
    execute do |scenario, left_subscript, left, right_subscript, right|
      subject.perform_logical(
        scenario: scenario,
        left: { value: left, subscript: left_subscript },
        right: { value: right, subscript: right_subscript },
        operation: :or
      )
    end
  end
end
