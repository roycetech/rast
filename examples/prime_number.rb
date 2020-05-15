# frozen_string_literal: true

# Example that returns true if the number passed is a prime number
class PrimeNumber
  def prime?(number)
    raise "Invalid number: #{number}" if number <= 0

    return false if number == 1

    compute_prime(number)
  end

  private

  def compute_prime(number)
    is_prime = true
    (2...number).each do |i|
      is_prime = number % i != 0
      break unless is_prime
    end

    is_prime
  end
end
