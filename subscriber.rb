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
    response = CreateSend.get "/subscribers/#{list_id}.json", { :query => { :email => email_address } }
    Hashie::Mash.new(response)
  end
end