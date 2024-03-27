require 'date'

class ShipmentCalculator
  def initialize
    @shipping_prices = {
      'LP' => {'S' => 1.50, 'M' => 4.90, 'L' => 6.90},
      'MR' => {'S' => 2.00, 'M' => 3.00, 'L' => 4.00}
    }
    @lp_l_discount = Hash.new(0.0)
    @discount_limit = 10.00
    @total_discount = Hash.new(0.0)
  end

  def calculate_discount(date, package_size, carrier)
    price = @shipping_prices[carrier][package_size]
    return '-', '-' if price.nil?

    discount = 0.00
    month_key = date.strftime('%Y-%m')

    if package_size == 'S' && (carrier == 'LP' || carrier == 'MR')
      min_s_price = [@shipping_prices['LP']['S'], @shipping_prices['MR']['S']].min
      if min_s_price != price
        discount = min_s_price - price
        price = min_s_price
        if discount.abs + @total_discount[month_key] > @discount_limit
          discount = @discount_limit - @total_discount[month_key]
          price = @shipping_prices['MR']['S'] - discount
        end
        @total_discount[month_key] += discount.abs
      end
    elsif package_size == 'L' && carrier == 'LP'
      count = @lp_l_discount[month_key] ||= 0
      if count == 2
        discount = @shipping_prices['LP']['L']
        if discount.abs + @total_discount[month_key] > @discount_limit
          discount = @discount_limit - @total_discount[month_key]
        end
        @total_discount[month_key] += discount.abs
        price = @shipping_prices['LP']['L'] - discount
      end
      @lp_l_discount[month_key] += 1
    end

    discount_value = (discount == 0.00 ? '-' : format('%.2f', discount.abs))

    [format('%.2f', price), discount_value]
  end

  def process_shipments(input_file = Rails.root.join('public', 'data', 'input.txt'))
    begin
      File.foreach(input_file) do |line|
        parts = line.strip.split
        date_str, package_size, carrier = parts
        if !%w[LP MR].include?(carrier) || !%w[S M L].include?(package_size)
          puts "#{date_str} #{carrier}#{package_size} Ignored"
          next
        end

        begin
          date = Date.parse(date_str)
        rescue ArgumentError
          puts 'Ignored'
          next
        end

        reduced_price, discount = calculate_discount(date, package_size, carrier)
        puts "#{date_str} #{package_size} #{carrier} #{reduced_price} #{discount}"
      end
    rescue Errno::ENOENT
      puts "File #{input_file} not found"
    end
  end
end
