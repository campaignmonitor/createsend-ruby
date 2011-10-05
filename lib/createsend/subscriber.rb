require 'createsend'
require 'json'

module CreateSend
  # Represents a subscriber and associated functionality.
  class Subscriber
    attr_reader :list_id
    attr_reader :email_address

    def initialize(list_id, email_address)
      @list_id = list_id
      @email_address = email_address
    end

    # Gets a subscriber by list ID and email address.
    def self.get(list_id, email_address)
      options = { :query => { :email => email_address } }
      response = CreateSend.get "/subscribers/#{list_id}.json", options
      Hashie::Mash.new(response)
    end

    # Adds a subscriber to a subscriber list.
    def self.add(list_id, email_address, name, custom_fields, resubscribe)
      options = { :body => {
        :EmailAddress => email_address,
        :Name => name,
        :CustomFields => custom_fields,
        :Resubscribe => resubscribe }.to_json }
      response = CreateSend.post "/subscribers/#{list_id}.json", options
      response.parsed_response
    end

    # Imports subscribers into a subscriber list.
    def self.import(list_id, subscribers, resubscribe, queue_subscription_based_autoresponders=false)
      options = { :body => {
        :Subscribers => subscribers,
        :Resubscribe => resubscribe,
        :QueueSubscriptionBasedAutoresponders => queue_subscription_based_autoresponders }.to_json }
      begin
        response = CreateSend.post "/subscribers/#{list_id}/import.json", options
      rescue BadRequest => br
        # Subscriber import will throw BadRequest if some subscribers are not imported
        # successfully. If this occurs, we want to return the ResultData property of
        # the BadRequest exception (which is of the same "form" as the response we'd 
        # receive upon a completely successful import)
        if br.data.ResultData
          return br.data.ResultData
        else
          raise br
        end
      end
      Hashie::Mash.new(response)
    end

    # Updates any aspect of a subscriber, including email address, name, and 
    # custom field data if supplied.
    def update(new_email_address, name, custom_fields, resubscribe)
      options = {
        :query => { :email => @email_address },
        :body => {
          :EmailAddress => new_email_address,
          :Name => name,
          :CustomFields => custom_fields,
          :Resubscribe => resubscribe }.to_json }
      CreateSend.put "/subscribers/#{@list_id}.json", options
      # Update @email_address, so this object can continue to be used reliably
      @email_address = new_email_address
    end

    # Unsubscribes this subscriber from the associated list.
    def unsubscribe
      options = { :body => {
        :EmailAddress => @email_address }.to_json }
      CreateSend.post "/subscribers/#{@list_id}/unsubscribe.json", options
    end

    # Gets the historical record of this subscriber's trackable actions.
    def history
      options = { :query => { :email => @email_address } }
      response = CreateSend.get "/subscribers/#{@list_id}/history.json", options
      response.map{|item| Hashie::Mash.new(item)}
    end

    # Moves this subscriber to the Deleted state in the associated list.
    def delete
      options = { :query => { :email => @email_address } }
      CreateSend.delete "/subscribers/#{@list_id}.json", options
    end
  end
end