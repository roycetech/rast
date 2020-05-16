# Getting Started (WIP)

### A Basic Example

Suppose we want to create a class that checks if a number is a positive number or not.

#### Create a spec file `spec/positive_spec.rb`

```ruby
require 'rast'

rast Positive do
  spec 'Is Positive Example' do
    execute { |number| subject.positive?(number) }
  end
end
```

#### Create a spec configuration `spec/rast/positive_spec.yml`

```yaml
specs:
  Is Positive Exaple:
    variables: {number: [-1, 0, 1]}
    outcomes: {true: 1}
```

The class to test:

```ruby
# positive.rb
class Positive
  def positive?(number)
    number > 0
  end
end
```

Running the test:

`$ rspec -fd spec/examples/positive_spec.rb` 

Test result:

```
Positive: #positive?
  [false]=[number: -1]
  [false]=[number: 0]
  [true]=[number: 1]

Finished in 0.00471 seconds (files took 0.47065 seconds to load)
3 examples, 0 failures
```

## How To's

