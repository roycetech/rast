# frozen_string_literal: true

require './lib/rast'
require './examples/hotel_finder'

rast HotelFinder do
  spec '#applicable?' do
    prepare do |with_ac, is_opererational, with_security, security_grade|
      if with_ac
        allow(subject)
          .to receive(:aircon) { double(operational?: is_opererational) }
      end

      if with_security
        allow(subject)
          .to receive(:security) { double(grade: security_grade.to_sym) }
      end
    end

    execute { subject.applicable? ? :PASSED : :INADEQUATE }
  end
end
