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
      # if duplicates.include?(outcome)
      #   raise "#{outcome} matched multiple clauses"
      # end

      # duplicates << outcome

      @outcome_clause_hash[outcome.to_s] = Rule.sanitize(clause: clause)
    end
  end

  def self.sanitize(clause: '')
    return clause if clause.is_a?(Array)

    cleaner = Rule.remove_spaces(token: clause, separator: '(')
    cleaner = Rule.remove_spaces(token: cleaner, separator: ')')
    cleaner = Rule.remove_spaces(token: cleaner, separator: '&')
    cleaner = Rule.remove_spaces(token: cleaner, separator: '|')
    Rule.remove_spaces(token: cleaner, separator: '!').strip
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
  def self.remove_spaces(token: nil, separator: '')
    escape = %w[( ) |].include?(separator) ? '\\' : ''
    token.to_s.gsub(Regexp.new("\\s*#{escape}#{separator}\\s*"), separator)
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
end
