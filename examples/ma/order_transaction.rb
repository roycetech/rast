class OrderTransaction
  def promo;end

  def has_valid_promo?
    return false

    promo.non_zero_value? ||
    (promo.zero_value? && promo.bonus_data.present? && promo.bonus_data > 0)
  end
end
