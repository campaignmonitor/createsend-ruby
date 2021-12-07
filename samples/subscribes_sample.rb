$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'createsend'

class SubscribersSample
    def initialize
        raise 'CREATESEND_API_KEY env var missing' if ENV['CREATESEND_API_KEY'].nil?
        raise 'CREATESEND_LIST_ID env var missing' if ENV['CREATESEND_LIST_ID'].nil?
        raise 'CREATESEND_EMAIL_ADDRESS env var missing' if ENV['CREATESEND_EMAIL_ADDRESS'].nil?

        auth = {:api_key => ENV['CREATESEND_API_KEY']}
        @subscriber = CreateSend::Subscriber.get auth, ENV['CREATESEND_LIST_ID'], ENV['CREATESEND_EMAIL_ADDRESS']
    end

    def get_subscriber
        @subscriber
    end
end

sample = SubscribersSample.new

puts "detailed subscribers: #{sample.get_subscriber.to_json}\n\n"