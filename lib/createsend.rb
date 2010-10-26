require 'rubygems'
require 'cgi'
require 'uri'
require 'httparty'
require 'hashie'
Hash.send :include, Hashie::HashExtensions

libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'client'
require 'campaign'
require 'list'
require 'subscriber'
require 'template'

class CreateSendError < StandardError
  attr_reader :data
  def initialize(data)
    @data = data
    super
  end
end

class ClientError < StandardError; end
class ServerError < StandardError; end
class BadRequest < CreateSendError; end
class Unauthorized < ClientError; end
class NotFound < ClientError; end
class Unavailable < StandardError; end

class CreateSend
  include HTTParty
  headers 'Content-Type' => 'application/json'

  # :api_key => 'xxxxxxxxxxxxxxxxxxxxxxxx', :base_uri => 'http://api.createsend.com/api/v3'
  def initialize(config={})
    if config[:api_key].nil? or config[:base_uri].nil?
      config = YAML.load_file('config.yaml')
      @api_key = config['api_key']
      self.class.base_uri config['base_uri']
    else
      @api_key = config[:api_key]
      self.class.base_uri config[:base_uri]
    end
    self.class.basic_auth @api_key, 'x'
  end
  
  def apikey(site_url, username, password) 
    site_url = CGI.escape(site_url)
    self.class.basic_auth username, password
    response = CreateSend.get("/apikey.json?SiteUrl=#{site_url}")
    # Revert basic_auth to use @api_key, 'x'
    self.class.basic_auth @api_key, 'x'
    Hashie::Mash.new(response)
  end

  def clients
    response = CreateSend.get('/clients.json')
    response.map{|item| Hashie::Mash.new(item)}
  end

  def countries
    response = CreateSend.get('/countries.json')
    response.parsed_response
  end

  def systemdate
    response = CreateSend.get('/systemdate.json')
    Hashie::Mash.new(response)
  end

  def timezones
    response = CreateSend.get('/timezones.json')
    response.parsed_response
  end

  def self.get(*args); handle_response super end
  def self.post(*args); handle_response super end
  def self.put(*args); handle_response super end
  def self.delete(*args); handle_response super end

  def self.handle_response(response)
    case response.code
    when 400
      raise BadRequest.new(response)
    when 401
      raise Unauthorized.new
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
