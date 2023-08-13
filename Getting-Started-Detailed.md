# Getting Started (WIP)


## Tutorials



### Writing a simple test.

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

- On line: 1, the library is required:

```ruby
require 'rast'
```

- On line: 3, invoke the DSL:

```ruby
rast Positive do
```
`Positive` is the fully qualified name of the class or the module to be tested.

- On line: 4, define the first spec:

```ruby
  spec 'Is Positive Example' do
```

`'Is Positive Example'` is a descriptive identifier for the test. It can be the name of the method like `#positive?`.

- On line: 5, define the `execute` block..

```ruby
execute { |number| subject.positive?(number) }
```

There is a lot going on here.<br>
- Inside the block, we define how our subject will be invoked. The `positive?` method is invoked on the `subject`
accepting a parameter.
- Block parameter `number` will contain the test scenario we want to execute. More on this later. Just know that whichever values are passed here, the `subject` has to be able to handle it correctly.
- `subject` is an instance of the module or class that we defined on line: 3.
- And lastly, `execute` block expects a return value that will be verified when the spec is run.

#### Step 2: Defining outcomes and the variables that affects the test.

For the sake of simplicity, we will define the variables and outcomes in a separate YAML file, mainly because the next
steps are purely configurations. Using YAML is completely optional.

Create a folder `rast` in the same level as the spec file:

- spec
    - rast

Create a yaml file with the same name as the spec, but with `.yml` extension.

`spec/rast/positive_spec.yml` would contain:

```yaml
---
specs:
  Is Positive Example:
    variables: {number: [-1, 0, 1]}
    outcomes: {true: 1}
```

- On line: 1 is the root configuration element `specs` that will contain one or more specs.
- On line: 2 `Is Positive Example` is the spec identifier, this must match what we've defined on `positive_spec.rb:4`
- On line: 3, The variables that affect the SUT are defined, in this case there is only one variable called `number`,
which has 3 different possibilities `-1`, `0`, and `1`.
- On line: 4, This is where outcome to rule mapping is defined.

### The implementation file

positive.rb will have:

```ruby
class Positive
  def positive?(number)
    number > 0
  end
end
```

## How To's

### Use token subscript when there's a variable token clash.

In cases where multiple variables, `left` and `right`, has the same set of tokens `false` and `true`:

```yaml
    variables:
      left: [false, true]
      right: [false, true]
```

We need a way to uniquely identify the tokens in the `outcomes` configuration. We can do so by using a subscript in the format: `token[n]`
For Example:

```yaml
outcomes: {true: 'true[0] & true[1]'}
```

The subscript `0` would refer to the `true` token in the `left` variable and subscript `1` would refer to the `true`
token in the `right` variable.


## References

### Outcomes
