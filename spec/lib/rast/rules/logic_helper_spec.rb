# frozen_string_literal: true
require './lib/rast'
require './lib/rast/rules/logic_helper'

# Provides logic evaluation functionalities.
rast LogicHelper do
  spec '#perform_logical_and' do
    execute do |scenario, left_subscript, left, right_subscript, right|
      subject.perform_logical_and(
        scenario: scenario,
        left_subscript: left_subscript,
        left: left,
        right_subscript: right_subscript,
        right: right
      )
    end
  end

  # spec '#perform_logical_or' do
  #   execute do |scenario, left_subscript, left, right_subscript, right|
  #     subject.perform_logical_or
  #   end
  # end
end
