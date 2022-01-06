WaterDrop.setup do |config|
  config.deliver = Rails.env.production?
  config.kafka.seed_brokers = [Rails.env.production? ? 'kafka://prod-host:9091' : 'kafka://localhost:9092']
end
