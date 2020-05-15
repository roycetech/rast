# frozen_string_literal: true

# Example
class DoubleExample
  def sim; end

  def product; end

  def process
    return false if sim.nil? || product.nil?

    sim.best? && product.key == 'ayg'
  end
end
