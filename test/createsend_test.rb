require File.dirname(__FILE__) + '/helper'

class CreateSendTest < Test::Unit::TestCase
  context "when an api caller is authenticated" do
    setup do
      @api_key = '123123123123123123123'
      @base_uri = 'https://api.createsend.com/api/v3'
      CreateSend.api_key @api_key
      @cs = CreateSend::CreateSend.new
    end
    
    should "get api key" do
      uri = URI.parse(@base_uri)
      site_url = "http://iamadesigner.createsend.com/"
      username = "myusername"
      password = "mypassword"
      stub_get(nil, "https://#{username}:#{password}@#{uri.host}#{uri.path}/apikey.json?SiteUrl=#{CGI.escape(site_url)}", "apikey.json")
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
    setup do
      @api_key = '123123123123123123123'
      @base_uri = 'https://api.createsend.com/api/v3'
      CreateSend.api_key @api_key
      @cs = CreateSend::CreateSend.new
      @template = CreateSend::Template.new(:template_id => '98y2e98y289dh89h938389')
    end
    
    { ["400", "Bad Request"]  => CreateSend::BadRequest,
      ["401", "Unauthorized"] => CreateSend::Unauthorized,
      ["404", "Not Found"]    => CreateSend::NotFound,
      ["500", "Server Error"] => CreateSend::ServerError
    }.each do |status, exception|
      context "#{status.first}, a get" do
        should "raise a #{exception.name} error" do
          stub_get(@api_key, "countries.json", (status.first == '400' or status.first == '401') ? 'custom_api_error.json' : nil, status)
          lambda { c = @cs.countries }.should raise_error(exception)
        end
      end

      context "#{status.first}, a post" do
        should "raise a #{exception.name} error" do
          stub_post(@api_key, "clients.json", (status.first == '400' or status.first == '401') ? 'custom_api_error.json' : nil, status)
          lambda { CreateSend::Client.create "Client Company Name", "Client Contact Name", "client@example.com", 
            "(GMT+10:00) Canberra, Melbourne, Sydney", "Australia" }.should raise_error(exception)
        end
      end

      context "#{status.first}, a put" do
        should "raise a #{exception.name} error" do
          stub_put(@api_key, "templates/#{@template.template_id}.json", (status.first == '400' or status.first == '401') ? 'custom_api_error.json' : nil, status)
          lambda { @template.update "Template One Updated", "http://templates.org/index.html", 
            "http://templates.org/files.zip" }.should raise_error(exception)
        end
      end

      context "#{status.first}, a delete" do
        should "raise a #{exception.name} error" do
          stub_delete(@api_key, "templates/#{@template.template_id}.json", (status.first == '400' or status.first == '401') ? 'custom_api_error.json' : nil, status)
          lambda { @template.delete }.should raise_error(exception)
        end
      end
    end
  end
end
