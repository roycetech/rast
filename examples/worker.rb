# frozen_string_literal: true

# Example
class Worker
  def day_of_week; end

  def holiday?; end

  def goto_work?
    !holiday? && day_of_week != :Sunday
  end
end
