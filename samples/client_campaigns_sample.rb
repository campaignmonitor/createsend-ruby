$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'createsend'

class ClientCampaignsSample
    def initialize
        raise 'CREATESEND_API_KEY env var missing' if ENV['CREATESEND_API_KEY'].nil?
        raise 'CREATESEND_CLIENT_ID env var missing' if ENV['CREATESEND_CLIENT_ID'].nil?

        auth = {:api_key => ENV['CREATESEND_API_KEY']}
        @client = CreateSend::Client.new auth, ENV['CREATESEND_CLIENT_ID']
    end

    def get_all_sent_campaigns
        campaigns = []
        page_number = 1
        loop do
            page = @client.campaigns(page_number, 1000, 'desc', '', '', '')
            page_number += 1
            campaigns.concat(page.Results)
            if page.PageNumber == page.NumberOfPages
                break
            end
        end

        campaigns
    end

    def get_all_scheduled_campaigns
        @client.scheduled
    end

    def get_all_draft_campaigns
        @client.drafts
    end

    def get_all_client_tags
        @client.tags
    end
end

sample = ClientCampaignsSample.new

puts "First page of sent campaigns: #{sample.get_all_sent_campaigns.to_json}\n\n"
puts "All scheduled campaigns: #{sample.get_all_scheduled_campaigns.to_json}\n\n"
puts "All draft campaigns: #{sample.get_all_draft_campaigns.to_json}\n\n"
puts "All client tags: #{sample.get_all_client_tags.to_json}\n\n"