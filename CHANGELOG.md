# Change logs

## Unreleased


## Released

- 1.00.0
    - [maint] Updated for Ruby 3.0, updated Gemfiles. 

- 0.19.1

    - [bug] nil as configured outcome
    - [bug] nil showing in the report as empty string.

- 0.19.0 - [feature] boolean in variables definition to automatically infer
           false and true
           [feature] xrast to skip entire test.
           [feature] Add default outcome in yaml-less configuration. Default
           config will take higher precedence than boolean outcomes.

- 0.18.0 - [feature] xspec to skip a test
         - [feature] Added include rule to isolate scenarios.
         - [feature] Asterisk can be used as token character.
         - [bug] Duplicate outcome wasn't detected when there's default config.
         - [enhancement] Early return for 'and' and 'or' operators.
         - Add travis-ci build.
         - Add RubyGems badge
         - Update documentation.

- 0.17.0 - Allow default outcome for unmatched scenarios.
- 0.16.0 - Allow isolation of scenarios via include clause.
- 0.15.4 - Fix bug on logic checker for not operation.
- 0.15.3 - Fix use of boolean as key to the config.
         - Fix allow factory to be called inside both execute and prepare block.
- 0.15.2 - Fix handling of nil token, and big integers.
- 0.15.1 - Fix converters when variable is multi typed.
- 0.14.0 - Introduced an else config as substitute for pair.
- 0.13.0 - Make pair in config optional for boolean result.
- 0.12.0 - Allow non-string tokens in the rules.
- 0.11.6 - WIP moved factory girl as test and development dependency.
- 0.11.5 - Change factory girl dependency
- 0.11.4 - Fixed assert clash. Restored dependency to Factory girl.
- 0.11.2 - Remove dependency to Factory girl from gemspec. - YANKED!
- 0.11.1 - Add dependency to Factory girl, fixes to examples
- 0.11.0 - Raw array as clause to support spaces and operator characters.
- 0.10.0 - Optional variables definition for 1 to 1 rules.
- 0.9.0 - execute return value is now the expected outcome (removed result method)
- 0.8.1.pre - Allow spaces in rules.
- 0.8.0.pre - Auto-detect variable type.
- 0.7.0.pre - Display exclusion rule in the report
- 0.6.2.pre - Bugfix for 1D array of numbers scenario.
- 0.6.1.pre - Bugfix on the converters when used with rule exclusion.
- 0.6.0.pre - Reverted redesign.
- 0.5.0.pre - Redesigned to have subject as first block parameter. Everything inside
the prepare block now runs under the context of RSpec.
- 0.4.2.pre - Fix 4 tokens bug, due to mis-configured converters
- 0.4.1.pre - Fix negative? invocation.
- 0.4.0.pre - Allow yaml-less configuration.
- 0.3.1.pre - Fixed spec naming for modules.
- 0.3.0.pre - Support factory methods in execute block.
- 0.2.0.pre - Support module subjects.
- 0.1.2.pre - Fixed exclusions.
- 0.1.1.pre - Pre release version compatible with Ruby 2.0.0-p247