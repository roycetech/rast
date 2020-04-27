# frozen_string_literal: true

require './lib/rast'
require './examples/worker'

rast Worker do
  spec '#goto_work?' do
    prepare do |subject, day_type, dow|
      allow(subject).to receive(:day_of_week) { dow.to_sym }
      allow(subject).to receive(:holiday?) { day_type == 'Holiday' }
    end

    execute do
      result subject.goto_work? ? :Work : :Rest
    end
  end
end
