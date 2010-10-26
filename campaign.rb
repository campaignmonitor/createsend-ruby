require 'createsend'
require 'json'

class Campaign
  attr_reader :campaign_id

  def initialize(campaign_id)
    @campaign_id = campaign_id
  end

  def self.create(client_id, subject, name, from_name, from_email, reply_to, html_url,
    text_url, list_ids, segments)
    options = { :body => { 
      :Subject => subject,
      :Name => name,
      :FromName => from_name,
      :FromEmail => from_email,
      :ReplyTo => reply_to,
      :HtmlUrl => html_url,
      :TextUrl => text_url,
      :ListIDs => list_ids ,
      :Segments => segments }.to_json }
    response = CreateSend.post "/campaigns/#{client_id}.json", options
    response.parsed_response
  end
  
  private

  def get(action, options = {})
    CreateSend.get uri_for(action), options
  end

  def post(action, options = {})
    CreateSend.post uri_for(action), options
  end

  def put(action, options = {})
    CreateSend.put uri_for(action), options
  end

  def uri_for(action)
    "/campaigns/#{campaign_id}/#{action}.json"
  end

end
