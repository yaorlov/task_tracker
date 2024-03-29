WaterDrop.setup do |config|
  config.deliver = true
  config.kafka.seed_brokers = [Rails.env.production? ? 'kafka://prod-host:9091' : "kafka://#{ENV['KAFKA_URL']}"]
end
