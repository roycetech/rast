# frozen_string_literal: true

# Example
class DoubleExample
  def sim();end

  def process
    return false if sim.nil?

    sim.best?
  end
end
