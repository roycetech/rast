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
end
