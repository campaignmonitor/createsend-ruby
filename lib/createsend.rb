require 'cgi'
require 'uri'
require 'httparty'
require 'hashie'
Hash.send :include, Hashie::HashExtensions

libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'createsend/version'
require 'createsend/client'
require 'createsend/campaign'
require 'createsend/list'
require 'createsend/segment'
require 'createsend/subscriber'
require 'createsend/template'

module CreateSend

  # Just allows callers to do CreateSend.api_key "..." rather than CreateSend::CreateSend.api_key "..." etc
  class << self
    def new(api_key)
    	CreateSend::CreateSend.new api_key
    end
    
    def base_uri(uri)
      r = CreateSend.base_uri uri
    end
  end

  # Represents a CreateSend API error and contains specific data about the error.
  class CreateSendError < StandardError
    attr_reader :data
    def initialize(data)
      @data = data
      # @data should contain Code, Message and optionally ResultData
      extra = @data.ResultData ? "\nExtra result data: #{@data.ResultData}" : ""
      super "The CreateSend API responded with the following error - #{@data.Code}: #{@data.Message}#{extra}"
    end
  end

  class ClientError < StandardError; end
  class ServerError < StandardError; end
  class BadRequest < CreateSendError; end
  class Unauthorized < CreateSendError; end
  class NotFound < ClientError; end
  class Unavailable < StandardError; end

  # Provides high level CreateSend functionality/data you'll probably need.
  class CreateSend
    include HTTParty
    
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
  #  @api_key = ""
    headers({ 
      'User-Agent' => "createsend-ruby-#{VERSION}", 
      'Content-Type' => 'application/json; charset=utf-8',
      'Accept-Encoding' => 'gzip, deflate' })
    base_uri @@base_uri

		def initialize(api_key)
			@api_key = api_key
		end

    # Gets your CreateSend API key, given your site url, username and password.
    def apikey(site_url, username, password) 
      site_url = CGI.escape(site_url)
      self.class.basic_auth username, password
      response = CreateSend.get("/apikey.json?SiteUrl=#{site_url}")
      # Revert basic_auth to use @@api_key, 'x'
      self.class.basic_auth @api_key, 'x'
      Hashie::Mash.new(response)
    end

    # Gets your clients.
    def clients
      response = self.get('/clients.json')
      response.map{|item| Hashie::Mash.new(item)}
    end

    # Gets valid countries.
    def countries
      response = self.get('/countries.json')
      response.parsed_response
    end

    # Gets the current date in your account's timezone.
    def systemdate
      response = self.get('/systemdate.json')
      Hashie::Mash.new(response)
    end

    # Gets valid timezones.
    def timezones
      response = self.get('/timezones.json')
      response.parsed_response
    end

		def authenticate!
			self.class.basic_auth @api_key, 'x'
		end

		def get(*args)
			authenticate!
			self.class.get(*args)
		end
		
		def post(*args)
			authenticate!
			self.class.post(*args)
		end
		
		def put(*args)
			authenticate!
			self.class.put(*args)
		end
    
		def delete(*args)
			authenticate!
			self.class.delete(*args)
		end
		
		def self.get(*args); handle_response super end
    def self.post(*args); handle_response super end
    def self.put(*args); handle_response super end
    def self.delete(*args); handle_response super end

    def self.handle_response(response) # :nodoc:
      case response.code
      when 400
        raise BadRequest.new(Hashie::Mash.new response)
      when 401
        raise Unauthorized.new(Hashie::Mash.new response)
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