require File.dirname(__FILE__) + '/helper'

class CreateSendTest < Test::Unit::TestCase
  context "when an api caller is authenticated" do
    setup do
      @api_key = '123123123123123123123'
      @base_uri = 'http://api.createsend.com/api/v3'
      @cs = CreateSend.new(:api_key => @api_key, :base_uri => @base_uri)
    end
    
    should "get api key" do
      uri = URI.parse(@base_uri)
      site_url = "http://iamadesigner.createsend.com/"
      username = "myusername"
      password = "mypassword"
      stub_get(nil, "http://#{username}:#{password}@#{uri.host}#{uri.path}/apikey.json?SiteUrl=#{CGI.escape(site_url)}", "apikey.json")
      apikey = @cs.apikey(site_url, username, password).ApiKey
      apikey.should == "981298u298ue98u219e8u2e98u2"
    end

    should "get all clients" do
      stub_get(@api_key, "clients.json", "clients.json")
      clients = @cs.clients
      clients.size.should == 2
      clients.first.ClientID.should == '4a397ccaaa55eb4e6aa1221e1e2d7122'
      clients.first.Name.should == 'Client One'
    end
    
    should "get all countries" do
      stub_get(@api_key, "countries.json", "countries.json")
      countries = @cs.countries
      countries.size.should == 245
      assert countries.include? "Australia"
    end
    
    should "get system date" do
      stub_get(@api_key, "systemdate.json", "systemdate.json")
      systemdate = @cs.systemdate.SystemDate
      systemdate.should == "2010-10-15 09:27:00"
    end

    should "get all timezones" do
      stub_get(@api_key, "timezones.json", "timezones.json")
      timezones = @cs.timezones
      timezones.size.should == 97
      assert timezones.include? "(GMT+12:00) Fiji"
    end
  end

  context "when the CreateSend API responds with an error" do
    
    # TODO: Add tests for error case
    
  end
end
