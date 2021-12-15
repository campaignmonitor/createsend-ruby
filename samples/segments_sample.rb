$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'createsend'

class SegmentsSample
    def initialize
        raise 'CREATESEND_ACCESS_TOKEN env var missing' if ENV['CREATESEND_ACCESS_TOKEN'].nil?
        raise 'CREATESEND_REFRESH_TOKEN env var missing' if ENV['CREATESEND_REFRESH_TOKEN'].nil?
        raise 'CREATESEND_SEGMENT_ID env var missing' if ENV['CREATESEND_SEGMENT_ID'].nil?

        auth = {:access_token => ENV['CREATESEND_ACCESS_TOKEN'], :refresh_token => ENV['CREATESEND_REFRESH_TOKEN']}
        @segment = CreateSend::Segment.new auth, ENV['CREATESEND_SEGMENT_ID']
    end

    def get_active_subscribers
        @segment.subscribers
    end
end

sample = SegmentsSample.new

puts "All active subscribers: #{sample.get_active_subscribers.to_json}\n\n"