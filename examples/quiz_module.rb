# Used to determine if cards form quiz type
# S postfix means Single option, M postfix means Multiple options
module QuizModule
  RE_SELECTED = /(?<=\([*x]\)\s).*/.freeze
  RE_CHECKED = /(?<=\[[*x]\]\s).*/.freeze
  RE_WRONG_OPT_S = /(?<=\(\)\s).*/.freeze
  RE_WRONG_OPT_M = /(?<=\[\]\s).*/.freeze

  RE_QUIZ_OPTION_S = Regexp.new(
    "#{RE_WRONG_OPT_S}|#{RE_SELECTED}",
    Regexp::IGNORECASE
  )

  RE_QUIZ_OPTION_M = Regexp.new(
    "#{RE_WRONG_OPT_M}|#{RE_CHECKED}",
    Regexp::IGNORECASE
  )

  def quiz?(front = nil, back = nil)
    initialized = [true, false].include? @quiz
    @quiz = quiz_choice?(back) || quiz_fill_blank?(front) unless initialized
    @quiz
  end

  def quiz_choice?(back = nil)
    initialized = [true, false].include? @choice
    unless initialized
      @choice = quiz_single_choice?(back) || quiz_multi_choice?(back)
    end

    @choice
  end

  def quiz_multi_choice?(back)
    if back.is_a?(Array) && back.any?
      back.each { |element| return false unless element[RE_QUIZ_OPTION_M] }

      # Find at least 1 checked answer
      return false unless back.find do |element|
        true if element[RE_CHECKED]
      end

      @quiz = true
      @front_only = true
      return true
    end
    false
  end

  def quiz_single_choice?(back)
    if back.is_a?(Array) && back.any?
      back.each { |element| return false unless element[RE_QUIZ_OPTION_S] }

      # Find at least 1 selected answer
      selected = back.filter do |element|
        true if element[RE_SELECTED]
      end
      return false unless selected.size == 1

      @quiz = true
      @front_only = true
      return true
    end
    false
  end

  def quiz_fill_blank?(front)
    return true if (front.size == 1) && front.first[/_____/]

    false
  end

  private

  def choices_with_header(back)

  end
end
