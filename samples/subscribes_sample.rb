$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'createsend'

class SubscribersSample
    def initialize
        raise 'CREATESEND_ACCESS_TOKEN env var missing' if ENV['CREATESEND_ACCESS_TOKEN'].nil?
        raise 'CREATESEND_REFRESH_TOKEN env var missing' if ENV['CREATESEND_REFRESH_TOKEN'].nil?
        raise 'CREATESEND_LIST_ID env var missing' if ENV['CREATESEND_LIST_ID'].nil?
        raise 'CREATESEND_EMAIL_ADDRESS env var missing' if ENV['CREATESEND_EMAIL_ADDRESS'].nil?

        auth = {:access_token => ENV['CREATESEND_ACCESS_TOKEN'], :refresh_token => ENV['CREATESEND_REFRESH_TOKEN']}
        @subscriber = CreateSend::Subscriber.get auth, ENV['CREATESEND_LIST_ID'], ENV['CREATESEND_EMAIL_ADDRESS']
    end

    def get_subscriber
        @subscriber
    end
end

sample = SubscribersSample.new

puts "detailed subscribers: #{sample.get_subscriber.to_json}\n\n"