require 'date'
require_relative '../app/services/shipment_calculator'

RSpec.describe ShipmentCalculator do
  let(:calculator) { ShipmentCalculator.new }

  describe '#calculate_discount' do
    context 'when calculating discount for valid inputs' do
      it 'returns the correct reduced price and discount' do
        date = Date.parse('2024-03-08')

        reduced_price, discount = calculator.calculate_discount(date, 'S', 'MR')
        expect(reduced_price).to eq '1.50'
        expect(discount).to eq '0.50'

        reduced_price, discount = calculator.calculate_discount(date, 'L', 'LP')
        expect(reduced_price).to eq '6.90'
        expect(discount).to eq '-'

        reduced_price, discount = calculator.calculate_discount(date, 'M', 'MR')
        expect(reduced_price).to eq '3.00'
        expect(discount).to eq '-'
      end
    end

    context 'third LP L shipment discount' do
      it 'discounts the third LP L shipment' do
        date = Date.parse('2024-03-08')

        reduced_price, discount = calculator.calculate_discount(date, 'L', 'LP')
        expect(reduced_price).to eq '6.90'
        expect(discount).to eq '-'

        reduced_price, discount = calculator.calculate_discount(date, 'L', 'LP')
        expect(reduced_price).to eq '6.90'
        expect(discount).to eq '-'

        reduced_price, discount = calculator.calculate_discount(date, 'L', 'LP')
        expect(reduced_price).to eq '0.00'
        expect(discount).to eq '6.90'
      end
    end

    context 'when calculating discount for valid inputs' do
      it 'does not exceed the discount limit of 10 euros' do
        date = Date.parse('2024-03-08')
        total_discount = 0.0

        shipments = [
          { package_size: 'S', carrier: 'MR' },
          { package_size: 'S', carrier: 'MR' },
          { package_size: 'S', carrier: 'MR' },
          { package_size: 'L', carrier: 'LP' },
          { package_size: 'L', carrier: 'LP' },
          { package_size: 'L', carrier: 'LP' },
          { package_size: 'S', carrier: 'MR' },
          { package_size: 'S', carrier: 'MR' },
          { package_size: 'S', carrier: 'MR' },
          { package_size: 'S', carrier: 'MR' },
        ]

        shipments.each do |shipment|
          reduced_price, discount = calculator.calculate_discount(date, shipment[:package_size], shipment[:carrier])
          total_discount += discount.to_f
          break if total_discount >= 10.0
        end

        expect(total_discount).to be <= 10.0
      end
    end
  end
end
