# frozen_string_literal: true

require './examples/phone'

# This will guess the Phone class
FactoryGirl.define do
  factory :ayg, class: Phone do
    first_name { 'AS YOU GO' }

    factory :data do
      second_name { '2GB DATA' }
    end

    factory :unl do
      third_name { '1GB UNL' }
    end
  end
end
