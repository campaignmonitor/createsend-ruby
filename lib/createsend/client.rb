require 'createsend'
require 'json'

module CreateSend
  # Represents a client and associated functionality.
  class Client
    attr_reader :client_id

    def initialize(client_id)
      @client_id = client_id
    end

    # Creates a client.
    def self.create(company, contact_name, email, timezone, country)
      warn "[DEPRECATION] Use person.add or person.update to set the name on a particular person in a client. For now, we will create a default person with the name provided." unless contact_name.to_s == ''
      warn "[DEPRECATION] Use person.add or person.update to set the email on a particular person in a client. For now, we will create a default person with the email provided." unless email.to_s == ''
      
      options = { :body => { 
        :CompanyName => company, 
        :ContactName => contact_name,
        :EmailAddress => email,
        :TimeZone => timezone,
        :Country => country }.to_json }
      CreateSend.post "/clients.json", options
    end

    # Gets the details of this client.
    def details
      response = CreateSend.get "/clients/#{client_id}.json", {}
      Hashie::Mash.new(response)
    end

    # Gets the sent campaigns belonging to this client.
    def campaigns
      response = get 'campaigns'
      response.map{|item| Hashie::Mash.new(item)}
    end
    
    # Gets the currently scheduled campaigns belonging to this client.
    def scheduled
      response = get 'scheduled'
      response.map{|item| Hashie::Mash.new(item)}
    end

    # Gets the draft campaigns belonging to this client.
    def drafts
      response = get 'drafts'
      response.map{|item| Hashie::Mash.new(item)}
    end

    # Gets the subscriber lists belonging to this client.
    def lists
      response = get 'lists'
      response.map{|item| Hashie::Mash.new(item)}
    end

    # Gets the lists across a client, to which a subscriber with a particular
    # email address belongs.
    # email_address - A String representing the subcriber's email address
    def lists_for_email(email_address)
      options = { :query => { :email => email_address } }
      response = get 'listsforemail', options
      response.map{|item| Hashie::Mash.new(item)}
    end

    # Gets the segments belonging to this client.
    def segments
      response = get 'segments'
      response.map{|item| Hashie::Mash.new(item)}
    end
    
    # Gets the people associated with this client
    def people
      response = get "people"
      response.map{|item| Hashie::Mash.new(item)}
    end
    
    def get_primary_contact
      response = get "primarycontact"
      Hashie::Mash.new(response)
    end
    
    def set_primary_contact(email)
      options = { :query => { :email => email } }
      response = put "primarycontact", options
      Hashie::Mash.new(response)
    end

    # Gets this client's suppression list.
    def suppressionlist(page=1, page_size=1000, order_field="email", order_direction="asc")
      options = { :query => { 
        :page => page,
        :pagesize => page_size,
        :orderfield => order_field,
        :orderdirection => order_direction } }
      response = get 'suppressionlist', options
      Hashie::Mash.new(response)
    end

    # Gets the templates belonging to this client.
    def templates
      response = get 'templates'
      response.map{|item| Hashie::Mash.new(item)}
    end

    # Sets the basic details for this client.
    def set_basics(company, contact_name, email, timezone, country)
      warn "[DEPRECATION] Use person.update to set name on a particular person in a client. This will fail if there are multiple persons in a client." unless contact_name.to_s == ''
      warn "[DEPRECATION] Use person.update to set email on a particular person in a client. This will fail if there are multiple persons in a client." unless email.to_s == ''
            
      options = { :body => { 
        :CompanyName => company, 
        :ContactName => contact_name,
        :EmailAddress => email,
        :TimeZone => timezone,
        :Country => country }.to_json }
      put 'setbasics', options
    end

    # Sets the PAYG billing settings for this client.
    def set_payg_billing(currency, can_purchase_credits, client_pays, markup_percentage, 
      markup_on_delivery=0, markup_per_recipient=0, markup_on_design_spam_test=0)
      options = { :body => { 
        :Currency => currency,
        :CanPurchaseCredits => can_purchase_credits,
        :ClientPays => client_pays,
        :MarkupPercentage => markup_percentage,
        :MarkupOnDelivery => markup_on_delivery,
        :MarkupPerRecipient => markup_per_recipient,
        :MarkupOnDesignSpamTest => markup_on_design_spam_test }.to_json }
      put 'setpaygbilling', options
    end

    # Sets the monthly billing settings for this client.
    def set_monthly_billing(currency, client_pays, markup_percentage)
      options = { :body => { 
        :Currency => currency,
        :ClientPays => client_pays,
        :MarkupPercentage => markup_percentage }.to_json }
      put 'setmonthlybilling', options
    end
    
    # THIS METHOD IS DEPRECATED. It should only be used with existing integrations.
    # Sets the access settings for this client.
    def set_access(username, password, access_level)
      warn "[DEPRECATION] `set_access` is deprecated. Use Person.update to set access on a particular person in a client."
          
      options = { :body => { 
        :Username => username, 
        :Password => password, 
        :AccessLevel => access_level }.to_json }
      put 'setaccess', options
    end

    # Deletes this client.
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
end