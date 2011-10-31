require 'createsend'
require 'json'

module CreateSend
  # Represents a campaign and provides associated funtionality.
  class Campaign
    attr_reader :campaign_id

    def initialize(campaign_id)
      @campaign_id = campaign_id
    end

    # Creates a new campaign for a client.
    def self.create(client_id, subject, name, from_name, from_email, reply_to, html_url,
      text_url, list_ids, segment_ids)
      options = { :body => { 
        :Subject => subject,
        :Name => name,
        :FromName => from_name,
        :FromEmail => from_email,
        :ReplyTo => reply_to,
        :HtmlUrl => html_url,
        :TextUrl => text_url,
        :ListIDs => list_ids,
        :SegmentIDs => segment_ids }.to_json }
      response = CreateSend.post "/campaigns/#{client_id}.json", options
      response.parsed_response
    end

    # Sends a preview of this campaign.
    def send_preview(recipients, personalize="fallback")
      options = { :body => {
        :PreviewRecipients => recipients.kind_of?(String) ? [ recipients ] : recipients,
        :Personalize => personalize }.to_json }
      response = post "sendpreview", options
    end

    # Sends this campaign.
    def send(confirmation_email, send_date="immediately")
      options = { :body => {
        :ConfirmationEmail => confirmation_email,
        :SendDate => send_date }.to_json }
      response = post "send", options
    end

    # Unschedules this campaign if it is currently scheduled.
    def unschedule
      options = { :body => "" }
      response = post "unschedule", options
    end

    # Deletes this campaign.
    def delete
      response = CreateSend.delete "/campaigns/#{campaign_id}.json", {}
    end

    # Gets a summary of this campaign
    def summary
      response = get "summary", {}
      Hashie::Mash.new(response)
    end

    # Retrieves the lists and segments to which this campaaign will be (or was) sent.
    def lists_and_segments
      response = get "listsandsegments", {}
      Hashie::Mash.new(response)
    end

    # Retrieves the recipients of this campaign.
    def recipients(page=1, page_size=1000, order_field="email", order_direction="asc")
      options = { :query => { 
        :page => page,
        :pagesize => page_size,
        :orderfield => order_field,
        :orderdirection => order_direction } }
      response = get 'recipients', options
      Hashie::Mash.new(response)
    end

    # Retrieves the opens for this campaign.
    def opens(date, page=1, page_size=1000, order_field="date", order_direction="asc")
      options = { :query => { 
        :date => date,
        :page => page,
        :pagesize => page_size,
        :orderfield => order_field,
        :orderdirection => order_direction } }
      response = get "opens", options
      Hashie::Mash.new(response)
    end

    # Retrieves the subscriber clicks for this campaign.
    def clicks(date, page=1, page_size=1000, order_field="date", order_direction="asc")
      options = { :query => { 
        :date => date,
        :page => page,
        :pagesize => page_size,
        :orderfield => order_field,
        :orderdirection => order_direction } }
      response = get "clicks", options
      Hashie::Mash.new(response)
    end

    # Retrieves the unsubscribes for this campaign.
    def unsubscribes(date, page=1, page_size=1000, order_field="date", order_direction="asc")
      options = { :query => { 
        :date => date,
        :page => page,
        :pagesize => page_size,
        :orderfield => order_field,
        :orderdirection => order_direction } }
      response = get "unsubscribes", options
      Hashie::Mash.new(response)
    end

    # Retrieves the bounces for this campaign.
    def bounces(date="1900-01-01", page=1, page_size=1000, order_field="date", order_direction="asc")
      options = { :query => { 
        :date => date,
        :page => page,
        :pagesize => page_size,
        :orderfield => order_field,
        :orderdirection => order_direction } }
      response = get "bounces", options
      Hashie::Mash.new(response)
    end

    private

    def get(action, options = {})
      CreateSend.get uri_for(action), options
    end

    def post(action, options = {})
      CreateSend.post uri_for(action), options
    end

    def uri_for(action)
      "/campaigns/#{campaign_id}/#{action}.json"
    end

  end
end