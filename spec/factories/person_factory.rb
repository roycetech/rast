# frozen_string_literal: true

require './examples/person'

# This will guess the Phone class
FactoryGirl.define do
  factory :personal, class: Person do
    first_name { 'John' }

    factory :soldier do
      last_name { 'Ford' }
    end

    factory :musician do
      alias_name { 'Will.I.Am' }
    end
  end
end
