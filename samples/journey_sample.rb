$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'createsend'

class JourneySample
  @date = "2019-01-01 00:00"

  def initialize
    raise 'CREATESEND_API_KEY env var missing' if ENV['CREATESEND_API_KEY'].nil?
    raise 'CREATESEND_CLIENT_ID env var missing' if ENV['CREATESEND_CLIENT_ID'].nil?
    raise 'CREATESEND_JOURNEY_ID env var missing' if ENV['CREATESEND_JOURNEY_ID'].nil?
    raise 'CREATESEND_EMAIL_ID env var missing' if ENV['CREATESEND_EMAIL_ID'].nil?

    auth = {:api_key => ENV['CREATESEND_API_KEY']}
    @client = CreateSend::Client.new auth, ENV['CREATESEND_CLIENT_ID']
    @journey = CreateSend::Journey.new auth, ENV['CREATESEND_JOURNEY_ID']
  end

  def get_all_journeys
    @client.journeys
  end

  def get_journey_summary
    @journey.summary
  end

  def get_recipients_for_email
    @journey.email_recipients ENV['CREATESEND_EMAIL_ID']
  end

  def get_email_opens
    opens = []
    loop do
      page = @journey.email_opens email_id = ENV['CREATESEND_EMAIL_ID'], date = @date, order_direction = 'desc'
      opens.concat(page.Results)
      if page.PageNumber == page.NumberOfPages
        break
      end
    end
    opens
  end

  def get_email_clicks
    clicks = []
    loop do
      page = @journey.email_clicks email_id = ENV['CREATESEND_EMAIL_ID'], date = @date, order_direction = 'desc'
      clicks.concat(page.Results)
      if page.PageNumber == page.NumberOfPages
        break
      end
    end
    clicks
  end

  def get_email_unsubscribes
    unsubscribes = []
    loop do
      page = @journey.email_unsubscribes email_id = ENV['CREATESEND_EMAIL_ID'], date = @date, order_direction = 'desc'
      unsubscribes.concat(page.Results)
      if page.PageNumber == page.NumberOfPages
        break
      end
    end
    unsubscribes
  end

  def get_email_bounces
    bounces = []
    loop do
      page = @journey.email_bounces email_id = ENV['CREATESEND_EMAIL_ID'], date = @date, order_direction = 'asc'
      bounces.concat(page.Results)
      if page.PageNumber == page.NumberOfPages
        break
      end
    end
    bounces
  end
end

sample = JourneySample.new
puts "All journeys: #{sample.get_all_journeys.to_json}\n\n"
puts "Journey Summary: #{sample.get_journey_summary.to_json}\n\n"
puts "Email recipients : #{sample.get_recipients_for_email.to_json}\n\n"
puts "Email Opens : #{sample.get_email_opens.to_json}\n\n"
puts "Email Clicks : #{sample.get_email_clicks.to_json}\n\n"
puts "Email Unsubscribes : #{sample.get_email_unsubscribes.to_json}\n\n"
puts "Email Bounces : #{sample.get_email_bounces.to_json}\n\n"
