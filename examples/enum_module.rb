# frozen_string_literal: true

# Functions for detecting an enum.
module EnumModule
  def enum?(back_card)
    return false unless back_card.is_a?(Array) && back_card.any?

    return true if ordered?(back_card) || enum_with_header?(back_card)
    return false if detect_non_ol(back_card) || !same_prefix?(back_card)

    true
  end

  def ordered?(back_card)
    back_card.each_with_index do |item, index|
      return false unless item.start_with?("#{index + 1}. ")
    end

    true
  end

  private

  def detect_non_ol(back_card)
    back_card.each { |element| return true unless element[/^[-+*]\s.*/] }

    false
  end

  def enum_with_header?(back_card)
    return false if back_card.first[/^[-+*]\s.*/]

    back_card[1..back_card.size].each do |element|
      return false unless element[/^[-+*]\s.*/]
    end

    true
  end

  def same_prefix?(back_card)
    prefix = back_card.first[0, 2]
    back_card_rest = back_card - [back_card.first]
    back_card_rest.all? { |list_item| list_item.start_with?(prefix) }
  end
end
