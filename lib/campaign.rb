require 'createsend'
require 'json'

class Campaign
  attr_reader :campaign_id

  def initialize(campaign_id)
    @campaign_id = campaign_id
  end

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

  def test(recipients, personalize="fallback")
    options = { :body => {
      :TestRecipients => recipients.kind_of?(String) ? [ recipients ] : recipients,
      :Personalize => personalize }.to_json }
    response = post "test", options
  end
  
  def send(confirmation_email, send_date="immediately")
    options = { :body => {
      :ConfirmationEmail => confirmation_email,
      :SendDate => send_date }.to_json }
    response = post "send", options
  end

  def delete
    response = CreateSend.delete "/campaigns/#{campaign_id}.json", {}
  end
  
  def summary
    response = get "summary", {}
    Hashie::Mash.new(response)
  end
  
  def lists
    response = get "lists", {}
    response.map{|item| Hashie::Mash.new(item)}
  end

  def segments
    # TODO: This needs to be implemented
    []
  end
  
  def opens(date)
    options = { :query => { :date => date } }
    response = get "opens", options
    response.map{|item| Hashie::Mash.new(item)}
  end
  
  def clicks(date)
    options = { :query => { :date => date } }
    response = get "clicks", options
    response.map{|item| Hashie::Mash.new(item)}
  end
  
  def unsubscribes(date)
    options = { :query => { :date => date } }
    response = get "unsubscribes", options
    response.map{|item| Hashie::Mash.new(item)}
  end
  
  def bounces
    response = get "bounces", {}
    response.map{|item| Hashie::Mash.new(item)}
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
