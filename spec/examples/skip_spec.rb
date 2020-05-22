# frozen_string_literal: true

require './lib/rast'

class Skip
end

xrast Skip do
end

rast String do
  xspec '#skip_rspec' do
  end
end
