# frozen_string_literal: true

# Rules
class Recruiter
  def score; end

  def position; end

  def assess
    case position
    when 'Manager'
      assess_manager(score)
    when 'Senior Engineer'
      assess_sr_engineer(score)
    when 'Engineer'
      assess_engineer(score)
    end
  end

  private

  # Shortlist score of 9, accept 10, and reject the rest
  def assess_manager(score)
    return 'Shortlist' if score == 9

    return 'Accept' if score == 10

    'Reject'
  end

  # Shortlist score of 8, accept 9 or 10, and reject the rest
  def assess_sr_engineer(score)
    return 'Shortlist' if score == 8

    return 'Accept' if score > 8

    'Reject'
  end

  # Score of 9 and above are overqualified, shortlist 7, accept 8, and reject the rest.
  def assess_engineer(score)
    return 'Over Qualified' if score > 8

    return 'Accept' if score == 8

    return 'Shortlist' if score == 7

    'Reject'
  end
end
