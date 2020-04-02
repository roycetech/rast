# frozen_string_literal: true

# Example that returns true if the number passed is a prime number
class PrimeNumber
  def prime?(number)
    is_prime = true
    raise "Invalid number: #{number}" if number <= 0

    if number == 1
      is_prime = false
    elsif number > 2
      (2...number).each do |i|
        is_prime = number % i != 0
        break unless is_prime
      end
    end
    is_prime
  end
end
