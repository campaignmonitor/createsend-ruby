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
    def self.create(company, timezone, country)
      options = { :body => {
        :CompanyName => company,
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
    def suppressionlist(page=1, page_size=1000, order_field="email",
      order_direction="asc")
      options = { :query => {
        :page => page,
        :pagesize => page_size,
        :orderfield => order_field,
        :orderdirection => order_direction } }
      response = get 'suppressionlist', options
      Hashie::Mash.new(response)
    end

    # Adds email addresses to a client's suppression list
    def suppress(emails)
      options = { :body => {
        :EmailAddresses => emails.kind_of?(String) ?
          [ emails ] : emails }.to_json }
      response = post "suppress", options
    end

    # Unsuppresses an email address by removing it from the the client's
    # suppression list
    def unsuppress(email)
      options = { :query => { :email => email }, :body => '' }
      response = put "unsuppress", options
    end

    # Gets the templates belonging to this client.
    def templates
      response = get 'templates'
      response.map{|item| Hashie::Mash.new(item)}
    end

    # Sets the basic details for this client.
    def set_basics(company, timezone, country)
      options = { :body => {
        :CompanyName => company,
        :TimeZone => timezone,
        :Country => country }.to_json }
      put 'setbasics', options
    end

    # Sets the PAYG billing settings for this client.
    def set_payg_billing(currency, can_purchase_credits, client_pays,
      markup_percentage, markup_on_delivery=0, markup_per_recipient=0,
      markup_on_design_spam_test=0)
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
    # monthly_scheme must be nil, Basic or Unlimited
    def set_monthly_billing(currency, client_pays, markup_percentage,
      monthly_scheme = nil)
      options = { :body => {
        :Currency => currency,
        :ClientPays => client_pays,
        :MarkupPercentage => markup_percentage,
        :MonthlyScheme => monthly_scheme }.to_json }
      put 'setmonthlybilling', options
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