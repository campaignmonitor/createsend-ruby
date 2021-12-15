$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'createsend'

class AuthorizationSample
    def initialize
        raise 'CREATESEND_API_KEY env var missing' if ENV['CREATESEND_API_KEY'].nil?
        raise 'CREATESEND_CLIENT_ID env var missing' if ENV['CREATESEND_CLIENT_ID'].nil?
        raise 'CREATESEND_OAUTH_CLIENT_ID env var missing' if ENV['CREATESEND_OAUTH_CLIENT_ID'].nil?
        raise 'CREATESEND_OAUTH_CLIENT_SECRET env var missing' if ENV['CREATESEND_OAUTH_CLIENT_SECRET'].nil?
        raise 'CREATESEND_OAUTH_REDIRECT_URL env var missing' if ENV['CREATESEND_OAUTH_REDIRECT_URL'].nil?
        raise 'CREATESEND_OAUTH_SCOPE env var missing' if ENV['CREATESEND_OAUTH_SCOPE'].nil?
       
        @createsendApiKey = ENV['CREATESEND_API_KEY']
        @oauthClientId = ENV['CREATESEND_OAUTH_CLIENT_ID']
        @oauthClientSecret = ENV['CREATESEND_OAUTH_CLIENT_SECRET']
        @oauthRedirectUrl = ENV['CREATESEND_OAUTH_REDIRECT_URL']
        @oauthScope = ENV['CREATESEND_OAUTH_SCOPE']

        @createsendApiKey = 'usCvraxxGylqnTiIWuV/t/hLMAEXOVWGT05hlxiZT1tuhbRfiNtp7xO9jWrlokEoxsLiOKDShqccC3Ohts1WEgJITUSBrC7N9+l8rzgDW9a0944+4IEI7wihr0y/tSDje/IvI8zchTN3xbvgcEMYSg=='
        @oauthClientId = '123642'
        @oauthClientSecret = '06DKpCHjLH51SRMnXxlU8PTR7VV2iVG3kIqdoC6gYm0W3xg1301S38m81DA11734IbjvSK0fE9x5Vi7a'
        @oauthRedirectUrl = 'https://appname.com/register',
        @oauthScope = 'SendCampaigns,ViewReports,AdministerAccount,ManageLists'
        )
    end

    def authentication_with_api_key
        auth = {:api_key => @createsendApiKey}
        @client = CreateSend::Client.new auth, @createsendClientId

        @client.scheduled
    end

    def get_authorise_url
        state = 'some state data'

        @authorize_url = CreateSend::CreateSend.authorize_url(@oauthClientId, @oauthRedirectUrl, @oauthScope, state);
    end

    def exchange_token(code)
        CreateSend::CreateSend.exchange_token(
            client_id=@oauthClientId,
            client_secret=@oauthClientSecret,
            redirect_uri=@oauthRedirectUrl,
            code=code # Get the code from the query string after hitting authorise url
            )
    end

    def authentication_with_oauth(access_token, refresh_token)
        auth = {:access_token => access_token, :refresh_token => refresh_token}
        @client = CreateSend::Client.new auth, @createsendClientId

        @client.scheduled
    end
end

sample = AuthorizationSample.new
authoriseUrl = sample.get_authorise_url
# hit the authorise url, where you would be redirected and receive the code parameter in the query string
access_token, expires_in, refresh_token = sample.exchange_token('code that you get once you hit authorize url')

puts "Getting scheduled campaigns with api authentication: #{sample.authentication_with_api_key.to_json}\n\n"
puts "Getting authorise url: #{authoriseUrl.to_json}\n\n"
puts "Getting access_token: #{access_token.to_json}\n\n"
puts "Getting scheduled campaigns with oauth authentication: #{sample.authentication_with_oauth(access_token, refresh_token).to_json}\n\n"


        @client.scheduled
    end
end
