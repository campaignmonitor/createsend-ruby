require 'createsend'
require 'json'

module CreateSend
  # Represents an administrator and associated functionality.
  class Administrator
    attr_reader :email_address

    def initialize(email_address)
      @email_address = email_address
    end

    # Gets an adminsitrator by email address.
    def self.get(email_address)
      options = { :query => { :email => email_address } }
      response = CreateSend.get "/admins.json", options
      Hashie::Mash.new(response)
    end

    # Adds an adminstrator to the account
    def self.add(email_address, name)
      options = { :body => {
        :EmailAddress => email_address,
        :Name => name
      }.to_json }
      response = CreateSend.post "/admins.json", options
      Hashie::Mash.new(response)
    end

    # Updates the administator details
    def update(new_email_address, name)
      options = {
        :query => { :email => @email_address },
        :body => {
          :EmailAddress => new_email_address,
          :Name => name
        }.to_json }
      CreateSend.put '/admins.json', options
      # Update @email_address, so this object can continue to be used reliably
      @email_address = new_email_address
    end

    # deletes this administrator from the account
    def delete
      options = { :query => { :email => @email_address } }
      CreateSend.delete '/admins.json', options
    end
  end
end