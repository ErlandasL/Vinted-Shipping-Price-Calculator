namespace :shipment do
  desc 'Process shipments using ShipmentCalculator'
  task process_shipments: :environment do
    calculator = ShipmentCalculator.new
    calculator.process_shipments
  end
end
