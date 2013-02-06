require File.dirname(__FILE__) + '/helper'

class CreateSendTest < Test::Unit::TestCase

  context "when an api caller requires createsend" do
    setup do
      @access_token = "h9898wu98u9dqjoijnwld"
      @refresh_token = "tGzv3JOkF0XG5Qx2TlKWIA"
      @api_key = "hiuhqiw78hiqhwdwdqwdqw2s2e2"
    end

    should "authenticate using an oauth access token" do
      CreateSend.oauth @access_token
      CreateSend.oauth.should == [@access_token, nil]
      CreateSend.api_key.should == nil
      CreateSend::CreateSend.headers['Authorization'].should == "Bearer #{@access_token}"
    end

    should "authenticate using an oauth access token and refresh token" do
      CreateSend.oauth @access_token, @refresh_token
      CreateSend.oauth.should == [@access_token, @refresh_token]
      CreateSend.api_key.should == nil
      CreateSend::CreateSend.headers['Authorization'].should == "Bearer #{@access_token}"
    end

    should "authenticate using an api key" do
      CreateSend.api_key @api_key
      CreateSend.api_key.should == @api_key
      CreateSend.oauth.should == [nil, nil]
      CreateSend::CreateSend.default_options[:basic_auth].should == {:username => @api_key, :password => 'x'}
    end

    should "refresh an access token given a refresh token" do
      options = {
        :body => fixture_file("refresh_oauth_token.json"),
        :content_type => "application/json; charset=utf-8" }
      FakeWeb.register_uri(:post, "https://api.createsend.com/oauth/token", options)
      new_access_token, new_refresh_token = CreateSend.refresh_token @refresh_token

      new_access_token.should == "SlAV32hkKG2e12e"
      new_refresh_token.should == "tGzv3JOkF0XG5Qx2TlKWIA"
      CreateSend.oauth.should == [new_access_token, new_refresh_token]
      CreateSend::CreateSend.headers['Authorization'].should == "Bearer #{new_access_token}"
    end

  end

  context "when an api caller is authenticated using oauth" do
    setup do
      @access_token = 'joidjOkF2e2e25Qx2Tli3je'
      @refresh_token = 'tGzv3JOkF0XG5Qx2TlKWIA'
      @auth_options = {:access_token => @access_token, :api_key => nil}
      CreateSend.oauth @access_token, @refresh_token
    end

    should "refresh the current access token" do
      options = {
        :body => fixture_file("refresh_oauth_token.json"),
        :content_type => "application/json; charset=utf-8" }
      FakeWeb.register_uri(:post, "https://api.createsend.com/oauth/token", options)
      new_access_token, new_refresh_token = CreateSend.refresh_token

      new_access_token.should == "SlAV32hkKG2e12e"
      new_refresh_token.should == "tGzv3JOkF0XG5Qx2TlKWIA"
      CreateSend.oauth.should == [new_access_token, new_refresh_token]
      CreateSend::CreateSend.headers['Authorization'].should == "Bearer #{new_access_token}"
    end
  end

  multiple_contexts "authenticated_using_oauth_context", "authenticated_using_api_key_context" do
    setup do
      @cs = CreateSend::CreateSend.new
    end

    should "include the CreateSend module VERSION constant as part of the user agent when making a call" do
      # This test is done to ensure that the version from HTTParty isn't included instead
      assert CreateSend::CreateSend.headers["User-Agent"] == "createsend-ruby-#{CreateSend::VERSION}"
      stub_get(@auth_options, "clients.json", "clients.json")
      clients = @cs.clients
      clients.size.should == 2
    end

    should "get api key" do
      uri = URI.parse(@base_uri)
      site_url = "http://iamadesigner.createsend.com/"
      username = "myusername"
      password = "mypassword"
      auth_options = {:access_token => nil, :api_key => nil}
      stub_get(auth_options, "https://#{username}:#{password}@#{uri.host}#{uri.path}/apikey.json?SiteUrl=#{CGI.escape(site_url)}", "apikey.json")
      apikey = @cs.apikey(site_url, username, password).ApiKey
      apikey.should == "981298u298ue98u219e8u2e98u2"
      if @auth_options[:api_key]
        CreateSend::CreateSend.default_options[:basic_auth].should == {:username => @auth_options[:api_key], :password => 'x'}
      elsif
        CreateSend::CreateSend.default_options[:basic_auth].should == nil
      end
    end

    should "get all clients" do
      stub_get(@auth_options, "clients.json", "clients.json")
      clients = @cs.clients
      clients.size.should == 2
      clients.first.ClientID.should == '4a397ccaaa55eb4e6aa1221e1e2d7122'
      clients.first.Name.should == 'Client One'
    end

    should "get billing details" do
      stub_get(@auth_options, "billingdetails.json", "billingdetails.json")
      bd = @cs.billing_details
      bd.Credits.should == 3021
    end

    should "get all countries" do
      stub_get(@auth_options, "countries.json", "countries.json")
      countries = @cs.countries
      countries.size.should == 245
      assert countries.include? "Australia"
    end
    
    should "get system date" do
      stub_get(@auth_options, "systemdate.json", "systemdate.json")
      systemdate = @cs.systemdate.SystemDate
      systemdate.should == "2010-10-15 09:27:00"
    end

    should "get all timezones" do
      stub_get(@auth_options, "timezones.json", "timezones.json")
      timezones = @cs.timezones
      timezones.size.should == 97
      assert timezones.include? "(GMT+12:00) Fiji"
    end
    
    should "get all administrators" do
      stub_get(@auth_options, "admins.json", "administrators.json")
      administrators = @cs.administrators
      administrators.size.should == 2
      administrators.first.EmailAddress.should == "admin1@blackhole.com"
      administrators.first.Name.should == 'Admin One'
      administrators.first.Status.should == 'Active'
    end

    should "set primary contact" do
      email = 'admin@blackhole.com'
      stub_put(@auth_options, "primarycontact.json?email=#{CGI.escape(email)}", 'admin_set_primary_contact.json')
      result = @cs.set_primary_contact email
      result.EmailAddress.should == email
    end

    should "get primary contact" do
      stub_get(@auth_options, "primarycontact.json", 'admin_get_primary_contact.json')
      result = @cs.get_primary_contact
      result.EmailAddress.should == 'admin@blackhole.com'
    end

  end

  context "when the CreateSend API responds with an error" do

    multiple_contexts "authenticated_using_oauth_context", "authenticated_using_api_key_context" do
      setup do
        @cs = CreateSend::CreateSend.new
        @template = CreateSend::Template.new('98y2e98y289dh89h938389')
      end

      { ["400", "Bad Request"]  => CreateSend::BadRequest,
        ["401", "Unauthorized"] => CreateSend::Unauthorized,
        ["404", "Not Found"]    => CreateSend::NotFound,
        ["500", "Server Error"] => CreateSend::ServerError
      }.each do |status, exception|
        context "#{status.first}, a get" do
          should "raise a #{exception.name} error" do
            stub_get(@auth_options, "countries.json", (status.first == '400' or status.first == '401') ? 'custom_api_error.json' : nil, status)
            lambda { c = @cs.countries }.should raise_error(exception)
          end
        end

        context "#{status.first}, a post" do
          should "raise a #{exception.name} error" do
            stub_post(@auth_options, "clients.json", (status.first == '400' or status.first == '401') ? 'custom_api_error.json' : nil, status)
            lambda { CreateSend::Client.create "Client Company Name", 
              "(GMT+10:00) Canberra, Melbourne, Sydney", "Australia" }.should raise_error(exception)
          end
        end

        context "#{status.first}, a put" do
          should "raise a #{exception.name} error" do
            stub_put(@auth_options, "templates/#{@template.template_id}.json", (status.first == '400' or status.first == '401') ? 'custom_api_error.json' : nil, status)
            lambda { @template.update "Template One Updated", "http://templates.org/index.html", 
              "http://templates.org/files.zip" }.should raise_error(exception)
          end
        end

        context "#{status.first}, a delete" do
          should "raise a #{exception.name} error" do
            stub_delete(@auth_options, "templates/#{@template.template_id}.json", (status.first == '400' or status.first == '401') ? 'custom_api_error.json' : nil, status)
            lambda { @template.delete }.should raise_error(exception)
          end
        end
      end
    end

    context "when authenticated using oauth and the access token has expired" do
      setup do
        @access_token = '98y98u98u98ue212'
        @refresh_token = 'kj9wud09wi0qi0w'
        @base_uri = 'https://api.createsend.com/api/v3'
        @auth_options = {:access_token => @access_token, :api_key => nil}
        CreateSend.oauth @access_token, @refresh_token
        @cs = CreateSend::CreateSend.new
      end

      should "raise a CreateSend::ExpiredOAuthToken error" do
        stub_get(@auth_options, "countries.json", "expired_oauth_token_api_error.json", ["401", "Unauthorized"])
        lambda { c = @cs.countries }.should raise_error(CreateSend::ExpiredOAuthToken)
      end
    end

  end

end
