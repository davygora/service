class BackeryService
  attr_reader :order

  def data
    [
      { name: 'Vegemite Scroll', code: 'VS5', packs: { 3 => 6.99, 5 => 8.99 } },
      { name: 'Blueberry Muffin', code: 'MB11', packs: { 2 => 9.95, 5 => 16.95, 8 => 24.95 } },
      { name: 'Croissant', code: 'CF', packs: { 3 => 5.95, 5 => 9.95, 9 => 16.99 } }
    ]
  end

  def initialize(order)
    @order = order
  end

  def call
    execute_order
  end

  private

  def format_order_to_hash(order)
    order = order.split("\n").reject!(&:empty?)
    order.map! { |i| i.split(' ', 2) }.to_h
  end

  def list_order
    format_order_to_hash(order)
  end

  def execute_order
    list_order.each do |pack, order_code|
      order_cost = 0
      product = data.select { |order| order[:code] == order_code }
      product_packs = product.first[:packs]
      available_packages = product.first[:packs].keys.sort.reverse
      pack_breakdown(pack.to_i, available_packages, []).each do |item|
        order_packs = item.sort.reverse.group_by { |e| e }.map { |k, v| [k, v.length] }.to_h if item.is_a?(Array)
        prepare_output(order_packs, product_packs, order_cost, pack, order_code) unless order_packs.nil? && order_cost.zero?
      end
    end
  end

  def pack_breakdown(number, list, result)
    list.each_with_index do |list_item, index|
      difference = number - list_item
      if difference > list[index + 1].to_i || difference.zero?
        result << list_item
        pack_breakdown(difference, list, result)
        return difference, result
      end
    end
  end

  def prepare_output(order_packs, available_packages, order_cost, pack, order_code)
    order_packs.merge(available_packages) do |_k, packs_count, cost_of_package|
      order_cost += packs_count * cost_of_package
    end
    puts "#{pack} #{order_code} $#{order_cost.round(2)}"
    order_packs.each_pair do |packs, count|
      puts "  #{count} x #{packs} $#{available_packages[packs]}"
    end
  end
end

order = "10 VS5\n\n14 MB11\n\n13 CF\n\n28 CF\n25 VS5"
BackeryService.new(order).call
