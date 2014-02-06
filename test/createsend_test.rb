require File.dirname(__FILE__) + '/helper'

class CreateSendTest < Test::Unit::TestCase

  context "when an api caller requires createsend" do
    setup do
      @access_token = "h9898wu98u9dqjoijnwld"
      @refresh_token = "tGzv3JOkF0XG5Qx2TlKWIA"
      @api_key = "hiuhqiw78hiqhwdwdqwdqw2s2e2"
    end

    should "authenticate using an oauth access token and refresh token" do
      auth = {
        :access_token => @access_token,
        :refresh_token => @refresh_token
      }
      cs = CreateSend::CreateSend.new auth
      cs.auth_details.should == auth
    end

    should "authenticate using an api key" do
      auth = {:api_key => @api_key}
      cs = CreateSend::CreateSend.new auth
      cs.auth_details.should == auth
    end

    should "get the authorization url without state included" do
      client_id = 8998879
      redirect_uri = 'http://example.com/auth'
      scope = 'ViewReports,CreateCampaigns,SendCampaigns'
      url = CreateSend::CreateSend.authorize_url(client_id, redirect_uri, scope)
      url.should == "https://api.createsend.com/oauth?client_id=8998879&redirect_uri=http%3A%2F%2Fexample.com%2Fauth&scope=ViewReports%2CCreateCampaigns%2CSendCampaigns"
    end

    should "get the authorization url with state included" do
      client_id = 8998879
      redirect_uri = 'http://example.com/auth'
      scope = 'ViewReports,CreateCampaigns,SendCampaigns'
      state = 89879287
      url = CreateSend::CreateSend.authorize_url(client_id, redirect_uri, scope, state)
      url.should == "https://api.createsend.com/oauth?client_id=8998879&redirect_uri=http%3A%2F%2Fexample.com%2Fauth&scope=ViewReports%2CCreateCampaigns%2CSendCampaigns&state=89879287"
    end

    should "exchange an OAuth token for an access token, 'expires in' value, and refresh token" do
      client_id = 8998879
      client_secret = 'iou0q9wud0q9wd0q9wid0q9iwd0q9wid0q9wdqwd'
      redirect_uri = 'http://example.com/auth'
      code = 'jdiwouo8uowi9o9o'
      options = {
        :body => fixture_file("oauth_exchange_token.json"),
        :content_type => "application/json; charset=utf-8" }
      FakeWeb.register_uri(:post, "https://api.createsend.com/oauth/token", options)
      access_token, expires_in, refresh_token = CreateSend::CreateSend.exchange_token(
        client_id, client_secret, redirect_uri, code)

      FakeWeb.last_request.body.should == "grant_type=authorization_code&client_id=8998879&client_secret=iou0q9wud0q9wd0q9wid0q9iwd0q9wid0q9wdqwd&redirect_uri=http%3A%2F%2Fexample.com%2Fauth&code=jdiwouo8uowi9o9o"
      access_token.should == "SlAV32hkKG"
      expires_in.should == 1209600
      refresh_token.should == "tGzv3JOkF0XG5Qx2TlKWIA"
    end

    should "raise an error when an attempt to exchange an OAuth token for an access token fails" do
      client_id = 8998879
      client_secret = 'iou0q9wud0q9wd0q9wid0q9iwd0q9wid0q9wdqwd'
      redirect_uri = 'http://example.com/auth'
      code = 'invalidcode'
      options = {
        :body => fixture_file("oauth_exchange_token_error.json"),
        :content_type => "application/json; charset=utf-8" }
      FakeWeb.register_uri(:post, "https://api.createsend.com/oauth/token", options)
      lambda { access_token, expires_in, refresh_token = CreateSend::CreateSend.exchange_token(
        client_id, client_secret, redirect_uri, code) }.should raise_error(
          Exception, 'Error exchanging code for access token: invalid_grant - Specified code was invalid or expired')
      FakeWeb.last_request.body.should == "grant_type=authorization_code&client_id=8998879&client_secret=iou0q9wud0q9wd0q9wid0q9iwd0q9wid0q9wdqwd&redirect_uri=http%3A%2F%2Fexample.com%2Fauth&code=invalidcode"
    end

    should "refresh an access token given a refresh token" do
      refresh_token = 'ASP95S4aR+9KsgfHB0dapTYxNA=='
      options = {
        :body => fixture_file("refresh_oauth_token.json"),
        :content_type => "application/json; charset=utf-8" }
      FakeWeb.register_uri(:post, "https://api.createsend.com/oauth/token", options)
      new_access_token, new_expires_in, new_refresh_token = CreateSend::CreateSend.refresh_access_token refresh_token

      FakeWeb.last_request.body.should == "grant_type=refresh_token&refresh_token=#{CGI.escape(refresh_token)}"
      new_access_token.should == "SlAV32hkKG2e12e"
      new_expires_in.should == 1209600
      new_refresh_token.should == "tGzv3JOkF0XG5Qx2TlKWIA"
    end

    should "raise an error when an attempt to refresh an access token fails" do
      refresh_token = 'ASP95S4aR+9KsgfHB0dapTYxNA=='
      options = {
        :body => fixture_file("oauth_refresh_token_error.json"),
        :content_type => "application/json; charset=utf-8" }
      FakeWeb.register_uri(:post, "https://api.createsend.com/oauth/token", options)
      lambda { access_token, expires_in, refresh_token = CreateSend::CreateSend.refresh_access_token(
        refresh_token) }.should raise_error(
          Exception, 'Error refreshing access token: invalid_grant - Specified refresh_token was invalid or expired')
      FakeWeb.last_request.body.should == "grant_type=refresh_token&refresh_token=#{CGI.escape(refresh_token)}"
    end

  end

  context "when an api caller is authenticated using oauth" do
    setup do
      @access_token = "ASP95S4aR+9KsgfHB0dapTYxNA=="
      @refresh_token = "5S4aASP9R+9KsgfHB0dapTYxNA=="
      @auth = {
        :access_token => @access_token,
        :refresh_token => @refresh_token
      }
    end

    should "refresh the current access token" do
      options = {
        :body => fixture_file("refresh_oauth_token.json"),
        :content_type => "application/json; charset=utf-8" }
      FakeWeb.register_uri(:post, "https://api.createsend.com/oauth/token", options)
      cs = CreateSend::CreateSend.new @auth
      new_access_token, new_expires_in, new_refresh_token = cs.refresh_token

      FakeWeb.last_request.body.should == "grant_type=refresh_token&refresh_token=#{CGI.escape(@auth[:refresh_token])}"
      new_access_token.should == "SlAV32hkKG2e12e"
      new_expires_in.should == 1209600
      new_refresh_token.should == "tGzv3JOkF0XG5Qx2TlKWIA"
      cs.auth_details.should == {
        :access_token => new_access_token,
        :refresh_token => new_refresh_token
      }
    end

    should "raise an error when an attempt to refresh the access token is made but refresh token is nil" do
      cs = CreateSend::CreateSend.new :access_token => 'any token', :refresh_token => nil
      lambda { new_access_token, new_refresh_token = cs.refresh_token }.should raise_error(
        Exception, '@auth_details[:refresh_token] does not contain a refresh token.')
    end

    should "raise an error when an attempt to refresh the access token is made but no there was no refresh token passed in" do
      cs = CreateSend::CreateSend.new :access_token => 'any token'
      lambda { new_access_token, new_refresh_token = cs.refresh_token }.should raise_error(
        Exception, '@auth_details[:refresh_token] does not contain a refresh token.')
    end

    should "raise an error when an attempt to refresh the access token is made but no there was no auth hash passed in" do
      cs = CreateSend::CreateSend.new
      lambda { new_access_token, new_refresh_token = cs.refresh_token }.should raise_error(
        Exception, '@auth_details[:refresh_token] does not contain a refresh token.')
    end

    should "raise an error when an attempt to refresh the access token is made but the refresh token is invalid" do
      refresh_token = 'ASP95S4aR+9KsgfHB0dapTYxNA=='
      cs = CreateSend::CreateSend.new :access_token => 'any token', :refresh_token => refresh_token
      options = {
        :body => fixture_file("oauth_refresh_token_error.json"),
        :content_type => "application/json; charset=utf-8" }
      FakeWeb.register_uri(:post, "https://api.createsend.com/oauth/token", options)
      lambda { access_token, expires_in, refresh_token = cs.refresh_token }.should raise_error(
          Exception, 'Error refreshing access token: invalid_grant - Specified refresh_token was invalid or expired')
    end

    should "raise a CreateSend::InvalidOAuthToken error when an access token is invalid" do
      cs = CreateSend::CreateSend.new @auth
      stub_get(@auth, "countries.json", "invalid_oauth_token_api_error.json", ["401", "Unauthorized"])
      lambda { c = cs.countries }.should raise_error(CreateSend::InvalidOAuthToken)
    end

    should "raise a CreateSend::ExpiredOAuthToken error when an access token is expired" do
      cs = CreateSend::CreateSend.new @auth
      stub_get(@auth, "countries.json", "expired_oauth_token_api_error.json", ["401", "Unauthorized"])
      lambda { c = cs.countries }.should raise_error(CreateSend::ExpiredOAuthToken)
    end

    should "raise a CreateSend::RevokedOAuthToken error when an access token is revoked" do
      cs = CreateSend::CreateSend.new @auth
      stub_get(@auth, "countries.json", "revoked_oauth_token_api_error.json", ["401", "Unauthorized"])
      lambda { c = cs.countries }.should raise_error(CreateSend::RevokedOAuthToken)
    end

  end

  multiple_contexts "authenticated_using_oauth_context", "authenticated_using_api_key_context" do
    setup do
      @cs = CreateSend::CreateSend.new @auth
    end

    should "include the correct user agent string when making a call" do
      CreateSend::CreateSend.headers["User-Agent"].should ==
        "createsend-ruby-#{CreateSend::VERSION}-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}-#{RUBY_PLATFORM}"
      stub_get(@auth, "clients.json", "clients.json")
      clients = @cs.clients
      clients.size.should == 2
    end

    should "allow a custom user agent string to be set when making a call" do
      CreateSend::CreateSend.user_agent "custom user agent"
      CreateSend::CreateSend.headers["User-Agent"].should == "custom user agent"
      stub_get(@auth, "clients.json", "clients.json")
      clients = @cs.clients
      clients.size.should == 2
      CreateSend::CreateSend.user_agent nil
    end

    should "get all clients" do
      stub_get(@auth, "clients.json", "clients.json")
      clients = @cs.clients
      clients.size.should == 2
      clients.first.ClientID.should == '4a397ccaaa55eb4e6aa1221e1e2d7122'
      clients.first.Name.should == 'Client One'
    end

    should "get billing details" do
      stub_get(@auth, "billingdetails.json", "billingdetails.json")
      bd = @cs.billing_details
      bd.Credits.should == 3021
    end

    should "get all countries" do
      stub_get(@auth, "countries.json", "countries.json")
      countries = @cs.countries
      countries.size.should == 245
      assert countries.include? "Australia"
    end
    
    should "get system date" do
      stub_get(@auth, "systemdate.json", "systemdate.json")
      systemdate = @cs.systemdate.SystemDate
      systemdate.should == "2010-10-15 09:27:00"
    end

    should "get all timezones" do
      stub_get(@auth, "timezones.json", "timezones.json")
      timezones = @cs.timezones
      timezones.size.should == 97
      assert timezones.include? "(GMT+12:00) Fiji"
    end
    
    should "get all administrators" do
      stub_get(@auth, "admins.json", "administrators.json")
      administrators = @cs.administrators
      administrators.size.should == 2
      administrators.first.EmailAddress.should == "admin1@blackhole.com"
      administrators.first.Name.should == 'Admin One'
      administrators.first.Status.should == 'Active'
    end

    should "set primary contact" do
      email = 'admin@blackhole.com'
      stub_put(@auth, "primarycontact.json?email=#{CGI.escape(email)}", 'admin_set_primary_contact.json')
      result = @cs.set_primary_contact email
      result.EmailAddress.should == email
    end

    should "get primary contact" do
      stub_get(@auth, "primarycontact.json", 'admin_get_primary_contact.json')
      result = @cs.get_primary_contact
      result.EmailAddress.should == 'admin@blackhole.com'
    end

    should "get an external session url" do
      email = "exammple@example.com"
      chrome = "None"
      url = "/subscribers"
      integrator_id = "qw989q8wud98qwyd"
      client_id = "9q8uw9d8u9wud"
      stub_put(@auth, "externalsession.json", "external_session.json")
      result = @cs.external_session_url email, chrome, url, integrator_id, client_id
      result.SessionUrl.should == "https://external1.createsend.com/cd/create/ABCDEF12/DEADBEEF?url=FEEDDAD1"
    end

  end

  context "when the CreateSend API responds with an error" do

    multiple_contexts "authenticated_using_oauth_context", "authenticated_using_api_key_context" do
      setup do
        @cs = CreateSend::CreateSend.new @auth
        @template = CreateSend::Template.new @auth, '98y2e98y289dh89h938389'
      end

      { ["400", "Bad Request"]  => CreateSend::BadRequest,
        ["401", "Unauthorized"] => CreateSend::Unauthorized,
        ["404", "Not Found"]    => CreateSend::NotFound,
        ["418", "I'm a teapot"] => CreateSend::ClientError,
        ["500", "Server Error"] => CreateSend::ServerError
      }.each do |status, exception|
        context "#{status.first}, a get" do
          should "raise a #{exception.name} error" do
            stub_get(@auth, "countries.json", (status.first == '400' or status.first == '401') ? 'custom_api_error.json' : nil, status)
            lambda { c = @cs.countries }.should raise_error(exception)
          end
        end

        context "#{status.first}, a post" do
          should "raise a #{exception.name} error" do
            stub_post(@auth, "clients.json", (status.first == '400' or status.first == '401') ? 'custom_api_error.json' : nil, status) 
            lambda { CreateSend::Client.create @auth, "Client Company Name",
              "(GMT+10:00) Canberra, Melbourne, Sydney", "Australia" }.should raise_error(exception)
          end
        end

        context "#{status.first}, a put" do
          should "raise a #{exception.name} error" do
            stub_put(@auth, "templates/#{@template.template_id}.json", (status.first == '400' or status.first == '401') ? 'custom_api_error.json' : nil, status)
            lambda { @template.update "Template One Updated", "http://templates.org/index.html", 
              "http://templates.org/files.zip" }.should raise_error(exception)
          end
        end

        context "#{status.first}, a delete" do
          should "raise a #{exception.name} error" do
            stub_delete(@auth, "templates/#{@template.template_id}.json", (status.first == '400' or status.first == '401') ? 'custom_api_error.json' : nil, status)
            lambda { @template.delete }.should raise_error(exception)
          end
        end
      end
    end

  end

end
