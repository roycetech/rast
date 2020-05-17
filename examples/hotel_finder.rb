# frozen_string_literal: true

# Example
class HotelFinder
  def aircon; end

  def security; end

  def applicable?
    return false if aircon.nil? || security.nil?

    aircon.operational? && security.grade == :diplomat
  end
end
