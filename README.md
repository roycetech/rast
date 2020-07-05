# Overview

RSpec All Scenario Testing

[![Gem Version](https://badge.fury.io/rb/rast.svg)](https://badge.fury.io/rb/rast)
[![Build Status](https://travis-ci.com/roycetech/rast.svg?branch=master)](https://travis-ci.com/roycetech/rast)
[![Test Coverage](https://api.codeclimate.com/v1/badges/280a80e7e03350b7a3d3/test_coverage)](https://codeclimate.com/github/roycetech/rast/test_coverage)
[![Maintainability](https://api.codeclimate.com/v1/badges/280a80e7e03350b7a3d3/maintainability)](https://codeclimate.com/github/roycetech/rast/maintainability)

This library runs on top of RSpec to provide basically a parameterized unit testing pattern. It follows a specific pattern of writing unit tests, enabling a predictable, complete and outputs a result that is simple to analyze.

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

Read the [documentation](./Documentation.md) for more examples.

## Contributing

### Definition of terms

- `spec` - as defined in the yaml file, the individual elements under `specs`
- `scenario` - a specific combination of tokens from vars, it can uniquely identify a fixture.
- `token` - used loosely to denote the individual variable in a rule. e.g. `true: you & me`, `you` and `me` are tokens.
- `fixture` - a hash containing a scenario, reference back to the spec, and the expected result for the given scenario.
- `variables` - raw list of variables to be combined into multiple fixtures.
- `rule` - set of outcomes, each paired with rule clause.
- `exclusions` - rule defining variable combinations to be excluded from the test.
- `inclusions` - rule that limits the scenarios to be included. Useful for isolating test cases.
- `outcome` - the left portion `us` of a rule e.g. `us: you&me`
- `clause` - the right portion `you&me` of a rule e.g. `us: you&me`

## Notes to author

When running the tests, the execution starts at the spec file, then invoking the
DSL. The DSL will then invoke the parameter generator to generate the scenarios.

### Releasing new features/bugfix

- Increment the [.gemspec](./.gemspec)
- Modify the [CHANGELOG.md](./CHANGELOG.md)

### Releasing GEM

- Build gem with `gem build rast.gemspec`
- Publish with `gem push <gem-filename>`

## References

[Semantic Versioning](https://semver.org)
