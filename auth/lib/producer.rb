# frozen_string_literal: true

class Producer
  def self.call(event, topic:)
    Rails.logger.info("\n==========")
    Rails.logger.info("Produced '#{topic}' event:")
    Rails.logger.info(event)
    Rails.logger.info("==========\n")
  end
end
