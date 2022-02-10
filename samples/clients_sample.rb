$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'createsend'

class ClientsSample
    def initialize
        raise 'CREATESEND_ACCESS_TOKEN env var missing' if ENV['CREATESEND_ACCESS_TOKEN'].nil?
        raise 'CREATESEND_REFRESH_TOKEN env var missing' if ENV['CREATESEND_REFRESH_TOKEN'].nil?
        raise 'CREATESEND_CLIENT_ID env var missing' if ENV['CREATESEND_CLIENT_ID'].nil?

        auth = auth = {:access_token => ENV['CREATESEND_ACCESS_TOKEN'], :refresh_token => ENV['CREATESEND_REFRESH_TOKEN']}
        @client = CreateSend::Client.new auth, ENV['CREATESEND_CLIENT_ID']
    end

    def get_all_sent_campaigns
        campaigns = []
        page_number = 1
        loop do
            page = @client.campaigns(page_number)
            page_number += 1
            campaigns.concat(page.Results)
            if page.PageNumber == page.NumberOfPages
                break
            end
        end

        campaigns
    end
    
    def get_sent_campaigns_with_tag_filter
        filtered_campaigns = []
        page_number = 1
        loop do
            page = @client.campaigns(page_number, 1000, 'desc', '', '', 'tag_example, tag_example_2')
            page_number += 1
            filtered_campaigns.concat(page.Results)
            if page.PageNumber == page.NumberOfPages
                break
            end
        end

        filtered_campaigns
    end

    def get_2021_sent_campaigns
        2021_campaigns = []
        page_number = 1
        loop do
            page = @client.campaigns(1, 1000, 'desc', '2021-01-01', '2022-01-01', '')
            page_number += 1
            2021_campaigns.concat(page.Results)
            if page.PageNumber == page.NumberOfPages
                break
            end
        end

        2021_campaigns
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

sample = ClientsSample.new

puts "All sent campaigns: #{sample.get_all_sent_campaigns.to_json}\n\n"
puts "All sent campaigns with `tag_example` and `tag_example_2` tag: #{sample.get_sent_campaigns_with_tag_filter.to_json}\n\n"
puts "All 2021 sent campaigns: #{sample.get_2021_sent_campaigns.to_json}\n\n"
puts "All scheduled campaigns: #{sample.get_all_scheduled_campaigns.to_json}\n\n"
puts "All draft campaigns: #{sample.get_all_draft_campaigns.to_json}\n\n"
puts "All client tags: #{sample.get_all_client_tags.to_json}\n\n"