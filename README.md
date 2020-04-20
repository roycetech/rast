# Overview
RSpec All Scenario Testing

## Definition of terms

spec - as defined in the yaml file, the individual elements under `specs`

scenario - a specific combination of tokens from vars, it can uniquely identify a fixture.

fixture - instance of a spec, containing a scenario, reference back to the spec, and the expected result for the given scenario.

vars - raw list of variables to be combined into multiple fixtures.

rule - set of outcome paired with rule clause.
exemption/exclusions - rule defining variable combinations to be excluded from the test.

outcome - the left portion of a rule e.g. `true: true&true`

clause - the right portion of a rule


##

When running the tests, the execution starts at the spec file, then invoking the
DSL. The DSL will then invoke the parameter generator to generate the scenarios.
