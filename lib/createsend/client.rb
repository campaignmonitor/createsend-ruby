require 'createsend'
require 'json'

module CreateSend
  # Represents a client and associated functionality.
  class Client
    attr_reader :api_key
    attr_reader :client_id
    attr_reader :username, :access_level
    attr_reader :company_name, :contact_name, :email_address, :country, :time_zone
    attr_reader :can_purchase_credits, :markup_on_design_spam_test, :client_pays, :base_rate_per_recipient,
        :markup_per_recipient, :markup_on_delivery, :base_delivery_rate, :currency, :base_design_span_test_rate

    def initialize(client_id, api_key, with_details = false)
      @client_id = client_id
      @api_key = api_key
      @create_send = CreateSend.new(@api_key)
      details if with_details
    end

    def self.create(company, contact_name, email, timezone, country, api_key)
      options = { :body => {
        :CompanyName => company,
        :ContactName => contact_name,
        :EmailAddress => email,
        :TimeZone => timezone,
        :Country => country }.to_json }
      CreateSend.new(api_key).post "/clients.json", options
    end

    # Gets the details of this client.
    def details
      response = @create_send.get "/clients/#{client_id}.json", {}

      hash = Hashie::Mash.new(response)
      combined_details = hash.select { |k, v|
        [ "BasicDetails", "AccessDetails", "BillingDetails" ].include?(k)
      }.values.reduce({}, &:merge)

      combined_details.each do |k, v|
        instance_variable_set :"@#{k.underscore}", v
      end

      hash
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

    # Gets the segments belonging to this client.
    def segments
      response = get 'segments'
      response.map{|item| Hashie::Mash.new(item)}
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
      options = { :body => {
        :CompanyName => company,
        :ContactName => contact_name,
        :EmailAddress => email,
        :TimeZone => timezone,
        :Country => country }.to_json }
      put 'setbasics', options
    end

    # Sets the access settings for this client.
    def set_access(username, password, access_level)
      options = { :body => {
        :Username => username,
        :Password => password,
        :AccessLevel => access_level }.to_json }
      put 'setaccess', options
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

    # Deletes this client.
    def delete
      @create_send.delete "/clients/#{client_id}.json", {}
    end

    private

    def get(action, options = {})
      @create_send.get uri_for(action), options
    end

    def post(action, options = {})
      @create_send.post uri_for(action), options
    end

    def put(action, options = {})
      @create_send.put uri_for(action), options
    end

    def uri_for(action)
      "/clients/#{client_id}/#{action}.json"
    end
  end
end
