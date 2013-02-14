require 'cgi'
require 'uri'
require 'httparty'
require 'hashie'
require 'json'

module CreateSend

  # Represents a CreateSend API error. Contains specific data about the error.
  class CreateSendError < StandardError
    attr_reader :data
    def initialize(data)
      @data = data
      # @data should contain Code, Message and optionally ResultData
      extra = @data.ResultData ? "\nExtra result data: #{@data.ResultData}" : ""
      super "The CreateSend API responded with the following error"\
        " - #{@data.Code}: #{@data.Message}#{extra}"
    end
  end

  # Raised for HTTP response codes of 400...500
  class ClientError < StandardError; end
  # Raised for HTTP response codes of 500...600
  class ServerError < StandardError; end
  # Raised for HTTP response code of 400
  class BadRequest < CreateSendError; end
  # Raised for HTTP response code of 401
  class Unauthorized < CreateSendError; end
  # Raised for HTTP response code of 404
  class NotFound < ClientError; end

  # Raised for HTTP response code of 401, specifically when an OAuth token
  # has expired (Code: 121, Message: 'Expired OAuth Token')
  class ExpiredOAuthToken < Unauthorized; end

  # Provides high level CreateSend functionality/data you'll probably need.
  class CreateSend
    include HTTParty
    attr_reader :auth_details

    # Get the authorization URL for your application, given the application's
    # client_id, client_secret, redirect_uri, scope, and optional state data.
    def self.authorize_url(client_id, client_secret, redirect_uri,
      scope, state=nil)
      qs = "client_id=#{CGI.escape(client_id.to_s)}"
      qs << "&client_secret=#{CGI.escape(client_secret.to_s)}"
      qs << "&redirect_uri=#{CGI.escape(redirect_uri.to_s)}"
      qs << "&scope=#{CGI.escape(scope.to_s)}"
      qs << "&state=#{CGI.escape(state.to_s)}" if state
      "#{@@oauth_base_uri}?#{qs}"
    end

    # Exchange a provided OAuth code for an OAuth access token, 'expires in'
    # value and refresh token.
    def self.exchange_token(client_id, client_secret, redirect_uri, code)
      body = "grant_type=authorization_code"
      body << "&client_id=#{CGI.escape(client_id.to_s)}"
      body << "&client_secret=#{CGI.escape(client_secret.to_s)}"
      body << "&redirect_uri=#{CGI.escape(redirect_uri.to_s)}"
      body << "&code=#{CGI.escape(code.to_s)}"
      options = {:body => body}
      response = HTTParty.post(@@oauth_token_uri, options)
      r = Hashie::Mash.new(response)
      [r.access_token, r.expires_in, r.refresh_token]
    end

    def initialize(*args)
      if args.size > 0
        auth args.first # Expect auth details as first argument
      end
    end

    # Deals with an unfortunate situation where responses aren't valid json.
    class Parser::DealWithCreateSendInvalidJson < HTTParty::Parser
      # The createsend API returns an ID as a string when a 201 Created
      # response is returned. Unfortunately this is invalid json.
      def parse
        begin
          super
        rescue MultiJson::DecodeError => e
          body[1..-2] # Strip surrounding quotes and return as is.
        end
      end
    end
    parser Parser::DealWithCreateSendInvalidJson
    @@base_uri = "https://api.createsend.com/api/v3"
    @@oauth_base_uri = "https://api.createsend.com/oauth"
    @@oauth_token_uri = "#{@@oauth_base_uri}/token"
    headers({
      'User-Agent' => "createsend-ruby-#{VERSION}",
      'Content-Type' => 'application/json; charset=utf-8',
      'Accept-Encoding' => 'gzip, deflate' })
    base_uri @@base_uri

    # Authenticate using either OAuth or an API key.
    def auth(auth_details)
      @auth_details = auth_details
    end

    # Refresh the current OAuth token using the current refresh token.
    def refresh_token
      if not @auth_details or
        not @auth_details.has_key? :refresh_token or
        not @auth_details[:refresh_token]
        raise '@auth_details[:refresh_token] does not contain a refresh token.'
      end

      options = {
        :body => "grant_type=refresh_token&refresh_token=#{@auth_details[:refresh_token]}" }
      response = HTTParty.post(@@oauth_token_uri, options)
      r = Hashie::Mash.new(response)
      auth({
        :access_token => r.access_token,
        :refresh_token => r.refresh_token})
      [r.access_token, r.refresh_token]
    end

    # Gets your CreateSend API key, given your site url, username and password.
    def apikey(site_url, username, password)
      site_url = CGI.escape(site_url)
      options = {:basic_auth => {:username => username, :password => password}}
      response = get("/apikey.json?SiteUrl=#{site_url}", options)
      result = Hashie::Mash.new(response)
      auth({:api_key => result.ApiKey}) if not @auth_details
      result
    end

    # Gets your clients.
    def clients
      response = get('/clients.json')
      response.map{|item| Hashie::Mash.new(item)}
    end

    # Get your billing details.
    def billing_details
      response = get('/billingdetails.json')
      Hashie::Mash.new(response)
    end

    # Gets valid countries.
    def countries
      response = get('/countries.json')
      response.parsed_response
    end

    # Gets the current date in your account's timezone.
    def systemdate
      response = get('/systemdate.json')
      Hashie::Mash.new(response)
    end

    # Gets valid timezones.
    def timezones
      response = get('/timezones.json')
      response.parsed_response
    end

    # Gets the administrators for the account.
    def administrators
      response = get('/admins.json')
      response.map{|item| Hashie::Mash.new(item)}
    end

    # Gets the primary contact for the account.
    def get_primary_contact
      response = get('/primarycontact.json')
      Hashie::Mash.new(response)
    end

    # Set the primary contect for the account.
    def set_primary_contact(email)
      options = { :query => { :email => email } }
      response = put("/primarycontact.json", options)
      Hashie::Mash.new(response)
    end

    def get(*args)
      args = add_auth_details_to_options(args)
      handle_response CreateSend.get(*args)
    end
    alias_method :cs_get, :get

    def post(*args)
      args = add_auth_details_to_options(args)
      handle_response CreateSend.post(*args)
    end
    alias_method :cs_post, :post

    def put(*args)
      args = add_auth_details_to_options(args)
      handle_response CreateSend.put(*args)
    end
    alias_method :cs_put, :put

    def delete(*args)
      args = add_auth_details_to_options(args)
      handle_response CreateSend.delete(*args)
    end
    alias_method :cs_delete, :delete

    def add_auth_details_to_options(args)
      if @auth_details
        options = {}
        if args.size > 1
          options = args[1]
        end
        if @auth_details.has_key? :access_token
          options[:headers] = {
            "Authorization" => "Bearer #{@auth_details[:access_token]}" }
        elsif @auth_details.has_key? :api_key
          if not options.has_key? :basic_auth
            options[:basic_auth] = {
              :username => @auth_details[:api_key], :password => 'x' }
          end
        end
        args[1] = options
      end
      args
    end

    def handle_response(response) # :nodoc:
      case response.code
      when 400
        raise BadRequest.new(Hashie::Mash.new response)
      when 401
        data = Hashie::Mash.new(response)
        if data.Code == 121
          raise ExpiredOAuthToken.new(data)
        end
        raise Unauthorized.new(data)
      when 404
        raise NotFound.new
      when 400...500
        raise ClientError.new
      when 500...600
        raise ServerError.new
      else
        response
      end
    end
  end
end