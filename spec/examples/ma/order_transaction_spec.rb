require 'rast'
require 'spec_helper'

require './examples/ma/order_transaction'

rast OrderTransaction do
  spec '#has_valid_promo?' do
    prepare do|with_promo, promo_price, bonus_data|
      if with_promo
        promo = {
          code: 'dummy code',
          order_reduction_value: promo_price,
          bonus_data: bonus_data
        }

        allow(subject).to receive(:promo) { promo }
      end
    end

    execute do
      result subject.has_valid_promo?
    end
  end

end
