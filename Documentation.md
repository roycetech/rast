# Documentation

## The YAML File

YAML is the preferred because it simplifies the content of the spec file. YAML contains the variables that affect the outcome, and the expected outcome based on rules that involve the said variables.

```yaml
specs:
  # spec key uniquely identifies a spec. It has to match the ID when the spec
  # block is invoked in the ruby spec file. Usually the method name.
  spec_key:
    description: Spec Description

    variables:
      param1: [one, two]

    outcomes:  # required (dictionary)
      true: one[0]  # sample outcome.

    default: DEFAULT  # optional (scalar) fall off value.
```

### Using a subscript when variables clash

A subscript may be used in cases where a variable token used multiple times.
In the example below, the left variable has the subscript of `0`, and the right variable have the subscript of `1`.

[logic_checker_spec.yml](./spec/examples/rast/logic_checker_spec.yml)

```yaml
specs:
  Logical AND:
    variables:
      left: [false, true]
      right: [false, true]
    outcomes: {true: 'true[0] & true[1]'}

  Logical OR:
    variables:
      left: [false, true]
      right: [false, true]
    outcomes: {true: 'true[0] | true[1]'}

  Logical XOR:
    variables:
      left: [false, true]
      right: [false, true]
    outcomes: {true: 'false[0] & true[1] | true[0] & false[1]'}
```

### Isolating scenarios

For troubleshooting purposes, you can use the `include` attribute to focus on one or more scenarios.

```yaml
---
specs:
  '#positive?':
    variables: {number: [-1, 0, 1]}
    outcomes: {true: 1}
    include: 0
```

Running `rspec -fd` will result to

```
Positive: #positive?, ONLY: '0'
  [false]=[number: 0]

Finished in 0.00292 seconds (files took 0.26024 seconds to load)
1 example, 0 failures
```


### Filtering Out Invalid Cases

In a prior example `HotelFinder`, some cases are invalid. For example, if an
 aircon is not available, then it makes no sense to check if it is operational
 not. In such case, we can limit the scenarios with `exclude` clause.

```yaml
# double_example_spec.yml
---
specs:
  '#applicable?':
    variables:
      Air Conditioning: [false, true]
      Security: [false, true]
      Operational: [false, true]
      Security Grade: [basic, advanced, diplomat]

    # If airconditioning is false, it does not make sense to test if it is
    # operational. We limit the invalid scenarios to at most 1, so that
    # a scenario where airconditioning is false will still be tested.
    exclude: false[0] & false[2] | false[1] & !basic
    outcomes: {PASSED: 'true[0] & true[1] & true[2] & diplomat'}
    else: INADEQUATE
```

### Using a default outcome

Defining the rules to outcomes can be the most time consuming part of the process
 especially for complex tests. If this example, we can remove the `ERROR` outcome
 and replace it with `default: ERROR` so that any scenario that don't fall into
 any of the defined outcomes, will result to the default.

```yaml
---
specs:
  '#prime?':
    variables:
      number: [-4, -1, 0, 1, 2, 3, 4, 5, 3331, 5551]

    outcomes:
      true: 2 | 3 | 5 | 3331
      false: 1 | 4 | 5551
      # ERROR: -4 | -1 | 0
    default: ERROR
```

Here is another simplified example of the above.  In case the outcome is of
 boolean type, we can omit the `default` altogether.
```yaml
---
specs:
  '#prime?':
    variables:
      number: [1, 2, 3, 4, 5, 3331, 5551]

    outcomes:
      true: 2 | 3 | 5 | 3331
```
The outcome will now be either `true` or `false`. Do note that the variables
 list have been simplified and does not check negative numbers for demo
 purpose only.

### Optional variables for 1 to 1 outcomes.

`variables` definition can be omitted when each outcome matches each variables.

```yaml
---
specs:
  '#person_name':
    outcomes:
      Will.I.Am: musician
      Ford: soldier
      John: personal
```

### Detecting invalid rule where a scenario matches multiple outcomes

In this example, the scenario `1` is defined to result in both `true`, and
`false`, which is impossible.

```yaml
---
specs:
  '#positive?':
    variables: {number: [-1, 0, 1]}
    outcomes: {true: 1, false: 1 | -1 | 0}
```

It will result in an error.

```
RuntimeError:
  #positive? [1] must fall into a unique rule outcome/clause, matched: ["true", "false"]
```

In the same way if a scenario does not fall into any outcome, a similar error
will be displayed.

```
RuntimeError:
  #positive? [1] must fall into a unique rule outcome/clause, matched: []
```

### Using special characters as part of variable tokens.

An array may be used as variable token, this will allow for the special
 characters like `!` to be used as part of the token without confusing the rule
 engine.

```yaml
---
specs:
  '#identify_sentence_type':
    variables:
      - "Let's do it!"
      - "Will this work?"
      - "Let's make a statement"
...

```

The rules must then be written in a different way, as arrays.

```yaml
...
    outcomes:
      exclamation: ["Let's do it!"]
      question: ['Will this work?']
      statement: ["Let's make a statement"]
```

If an operation is involved:

```yaml
outcomes:
  non-question: ["Let's do it!", '|', "Let's make a statement"]
```

## The spec file

### Stubbing

In this example, stubbing is done as you normally would. A `prepare` block is an
 optional block to organize the parts of the test into preparation and execution
 parts.

[worker_spec.rb](./spec/examples/worker_spec.rb)

```ruby
# spec/examples/worker_spec.rb
rast Worker do
  spec '#goto_work?' do
    prepare do |day_type, dow|
      allow(subject).to receive(:day_of_week) { dow.to_sym }
      allow(subject).to receive(:holiday?) { day_type == 'Holiday' }
    end

    execute { subject.goto_work? ? :Work : :Rest }
  end
end
```

### Using a factory

See [examples/factory_example.rb](./examples/factory_example.rb)

```ruby
rast FactoryExample do
  spec '#person_name' do
    prepare do |service_type|
      subject.instance_variable_set(:@person, build(service_type.to_sym))
    end

    execute { subject.person_name }
  end
end
```

### Using doubles

Suppose we have a HotelFinder class that has a dependency to air conditioning
 and security

 ```ruby
 rast DiplomatHotelFinder do
   spec '#applicable?' do
     prepare do |with_ac, is_opererational, with_security, security_grade|
       if with_ac
         allow(subject)
           .to receive(:aircon) { double(operational?: is_opererational) }
       end

       if with_security
         allow(subject)
           .to receive(:security) { double(grade: security_grade.to_sym) }
       end
     end

     execute { subject.applicable? ? :PASSED : :INADEQUATE }
   end
 end

 ```

### Spec file without yaml

If a single spec is preferred, like in cases where it's much simplier,
 the required configuration can be written with similar name except for the
 `inclusion` and `exclusion`.  The difference is due to the name clash with the
 `include` keyword in ruby.

```ruby
rast Positive do
  spec '#positive?' do
    variables({ number: [-1, 0, 1, 2, 3] })
    outcomes(true: 1)
    inclusion('!3')
    exclusion(2)
    execute { |number| subject.positive?(number) }
  end
end
```
