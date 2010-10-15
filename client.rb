require 'createsend'
require 'json'

class Client
  attr_reader :client_id

  def initialize(client_id)
    @client_id = client_id
  end
  
  def self.create(company, contact_name, email, timezone, country)
    options = { :body => { 
      :CompanyName => company, 
      :ContactName => contact_name,
      :EmailAddress => email,
      :TimeZone => timezone,
      :Country => country }.to_json }
    CreateSend.post "/clients.json", options
  end

  def details
    response = CreateSend.get "/clients/#{client_id}.json", {}
    Hashie::Mash.new(response)
  end

  def campaigns
    response = get 'campaigns'
    response.map{|item| Hashie::Mash.new(item)}
  end

  def drafts
    response = get 'drafts'
    response.map{|item| Hashie::Mash.new(item)}
  end

  def lists
    response = get 'lists'
    response.map{|item| Hashie::Mash.new(item)}
  end

  def segments
    response = get 'segments'
    response.map{|item| Hashie::Mash.new(item)}
  end

  def suppressionlist
    response = get 'suppressionlist'
    response.map{|item| Hashie::Mash.new(item)}
  end
  
  def templates
    response = get 'templates'
    response.map{|item| Hashie::Mash.new(item)}
  end

  def delete
    CreateSend.delete "/clients/#{client_id}.json", {}
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
    "/clients/#{client_id}/#{action}.json"
  end
end
