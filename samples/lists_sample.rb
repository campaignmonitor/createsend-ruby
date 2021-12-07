$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'createsend'

class ListsSample
    def initialize
        raise 'CREATESEND_API_KEY env var missing' if ENV['CREATESEND_API_KEY'].nil?
        raise 'CREATESEND_LIST_ID env var missing' if ENV['CREATESEND_LIST_ID'].nil?

        auth = {:api_key => ENV['CREATESEND_API_KEY']}
        @list = CreateSend::List.new auth, ENV['CREATESEND_LIST_ID']
    end

    def get_active_subscribers
        @list.active
    end

    def get_bounced_subscribers
        @list.bounced
    end

    def get_unsubscribed_subscribers
        @list.unsubscribed
    end

    def get_unconfirmed_subscribers
        @list.unconfirmed
    end

    def get_deleted_subscribers
        @list.deleted
    end
end

sample = ListsSample.new

puts "All active subscribers: #{sample.get_active_subscribers.to_json}\n\n"
puts "All bounced subscribers: #{sample.get_bounced_subscribers.to_json}\n\n"
puts "All unsubscribed subscribers: #{sample.get_unsubscribed_subscribers.to_json}\n\n"
puts "All unconfirmed subscribers: #{sample.get_unconfirmed_subscribers.to_json}\n\n"
puts "All deleted subscribers: #{sample.get_deleted_subscribers.to_json}\n\n"
