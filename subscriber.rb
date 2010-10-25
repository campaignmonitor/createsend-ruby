require 'createsend'
require 'json'

class Subscriber
  attr_reader :list_id
  attr_reader :email_address

  def initialize(list_id, email_address)
    @list_id = list_id
    @email_address = email_address
  end

  def self.get(list_id, email_address)
    options = { :query => { :email => email_address } }
    response = CreateSend.get "/subscribers/#{list_id}.json", options
    Hashie::Mash.new(response)
  end

  def self.add(list_id, email_address, name, custom_fields, resubscribe)
    options = { :body => {
      :EmailAddress => email_address,
      :Name => name,
      :CustomFields => custom_fields,
      :Resubscribe => resubscribe }.to_json }
    response = CreateSend.post "/subscribers/#{list_id}.json", options
    response.parsed_response
  end

  def self.import(list_id, subscribers, resubscribe)
    options = { :body => {
      :Subscribers => subscribers,
      :Resubscribe => resubscribe }.to_json }
    response = CreateSend.post "/subscribers/#{list_id}/import.json", options
    Hashie::Mash.new(response)
  end

  def unsubscribe
    options = { :body => {
      :EmailAddress => @email_address }.to_json }
    CreateSend.post "/subscribers/#{@list_id}/unsubscribe.json", options
  end

  def history
    options = { :query => { :email => @email_address } }
    response = CreateSend.get "/subscribers/#{@list_id}/history.json", options
    response.map{|item| Hashie::Mash.new(item)}
  end

end