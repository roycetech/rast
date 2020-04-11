# frozen_string_literal: true

# Represents a logical rule object.
class Rule
  # /**
  #  * TODO: Validation of the output_clause_src parameter.
  #  *
  #  * Instantiate a rule with the given clause. <br/>
  #  * <br/>
  #  * <b>Parameter Example:</b><br/>
  #  * Visible:Proposed|Approved<br/>
  #  * <br/>
  #  * Peace:Friendly|Indifferent\<br/>
  #  * ~War:Angry\<br/>
  #  * ~Neutral:Play safe
  #  */
  def initialize(rules: {})
    raise 'Must not have empty rules' if rules.empty?

    @outcome_clause_hash = {}
    # should have array of the rule pairs
    # rules = pActRuleSrc.split("~");
    duplicates = []

    rules.each do |outcome, clause|
      if duplicates.include?(outcome)
        raise "#{outcome} matched multiple clauses"
      end

      duplicates << outcome
      clause = remove_spaces(string: clause, separator: '\(')
      clause = remove_spaces(string: clause, separator: '\)')
      clause = remove_spaces(string: clause, separator: '&')
      clause = remove_spaces(string: clause, separator: '\|')
      clause = remove_spaces(string: clause, separator: '!')
      @outcome_clause_hash[outcome.to_s] = clause.strip
    end
  end

  def size
    @outcome_clause_hash.size
  end

  # /**
  #  * Removes the leading and trailing spaces of rule tokens.
  #  *
  #  * @param string rule clause.
  #  * @param separator rule clause token.
  #  */
  def remove_spaces(string: '', separator: '')
    string.gsub(Regexp.new("\\s*#{separator} \\s*"), separator)
  end

  # /**
  #  * @return the actionList
  #  */
  def outcomes
    @outcome_clause_hash.keys
  end

  # /**
  #  * @param action action which rule we want to retrieve.
  #  * @return the actionToRuleClauses
  #  */
  def clause(outcome: '')
    @outcome_clause_hash[outcome]
  end

  # /**
  #  * Get rule result give a fixed list of scenario tokens. Used for fixed
  #  * list.
  #  *
  #  * @param scenario of interest.
  #  * @return the actionToRuleClauses
  #  */
  def rule_outcome(scenario: [])
    scenario_string = scenario.to_s
    anded_scenario = scenario_string[1..-2].gsub(/,\s/, '&')

    @outcome_clause_hash.each do |key, clause|
      or_list_clause = clause.split('\|').map(&:strip)
      return key if or_list_clause.include?(anded_scenario)
    end
  end

  # /**
  #  * @see {@link Object#toString()}
  #  * @return String representation of this instance.
  #  */
  def to_s
    @outcome_clause_hash.to_s
  end
end
