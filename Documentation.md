# Documentation

##  Isolating scenarios

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
