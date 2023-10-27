$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'createsend'

class SubscribersSample
    def initialize
        raise 'CREATESEND_ACCESS_TOKEN env var missing' if ENV['CREATESEND_ACCESS_TOKEN'].nil?
        raise 'CREATESEND_REFRESH_TOKEN env var missing' if ENV['CREATESEND_REFRESH_TOKEN'].nil?
        raise 'CREATESEND_LIST_ID env var missing' if ENV['CREATESEND_LIST_ID'].nil?

        @auth = {:access_token => ENV['CREATESEND_ACCESS_TOKEN'], :refresh_token => ENV['CREATESEND_REFRESH_TOKEN']}
    end

    def add_subscriber_without_mobile
        @subscriberAdded = CreateSend::Subscriber.add @auth, ENV['CREATESEND_LIST_ID'], "subscriberNoMobile@example.com", "Subscriber", [], true, "Yes", false
    end

    def add_subscriber_with_mobile
        @subscriberAdded = CreateSend::Subscriber.add @auth, ENV['CREATESEND_LIST_ID'], "subscriberWithMobile@example.com", "SubscriberWithMobile", [], true, "Yes", false, "+61423152523"
    end

    def add_subscriber_with_mobile_and_consent
        @subscriberAdded = CreateSend::Subscriber.add @auth, ENV['CREATESEND_LIST_ID'], "subscriberWithMobileAndConsent@example.com", "SubscriberWithMobileAndConsent", [], true, "Yes", false, "+61423152523", "Yes"
    end

    def get_subscriber
        @subscriber = CreateSend::Subscriber.get @auth, ENV['CREATESEND_LIST_ID'], "subscriberNoMobile@example.com"
    end

    def import_subscribers
        subscribers = [
            {"EmailAddress":"subscriberImport11@example.com","Name":"subscriberImport11", "ConsentToTrack":"Yes"},
            {"EmailAddress":"subscriberImport12@example.com","Name":"subscriberImport12", "ConsentToTrack":"No", "MobileNumber":"+1612105111", "ConsentToSendSms":"Yes"},
            {"EmailAddress":"subscriberImport13@example.com","Name":"subscriberImport13", "ConsentToTrack":"Yes", "MobileNumber":"+1612105112"}
        ]
        @subscribersImported = CreateSend::Subscriber.import(@auth, ENV['CREATESEND_LIST_ID'], subscribers, true, false, false)
    end        

    def update_subscribers
        @subscriber = CreateSend::Subscriber.new(@auth, ENV['CREATESEND_LIST_ID'], 'subscriberWithMobileAndConsent@example.com')
        @subscriberUpdated = @subscriber.update("subscriberWithMobileAndConsent@example.com", "Subscriber With Mobile And Consent", [], true, "Yes", false, "+16175551218")
    end
end

sample = SubscribersSample.new

puts "add_subscriber_without_mobile: #{sample.add_subscriber_without_mobile.to_json}\n\n"
puts "add_subscriber_with_mobile: #{sample.add_subscriber_with_mobile.to_json}\n\n"
puts "add_subscriber_with_mobile_and_consent: #{sample.add_subscriber_with_mobile_and_consent.to_json}\n\n"
puts "get subscribers: #{sample.get_subscriber.to_json}\n\n"
puts "import_subscribers: #{sample.import_subscribers.to_json}\n\n"
puts "update_subscribers: #{sample.update_subscribers.to_json}\n\n"