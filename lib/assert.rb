# frozen_string_literal: true

# Used to provide assertion check similar to java
class AssertionError < RuntimeError
end

def assert(message)
  raise AssertionError(message) unless yield
end
