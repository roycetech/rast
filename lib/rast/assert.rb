# frozen_string_literal: true

# Used to provide assertion check similar to java

def assert(message)
  raise message unless yield
end
