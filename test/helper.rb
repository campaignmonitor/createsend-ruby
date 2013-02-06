require 'test/unit'
require 'pathname'

require 'shoulda'
require 'matchy'
require 'fakeweb'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'createsend'

FakeWeb.allow_net_connect = false

def fixture_file(filename)
  return '' if filename == ''
  file_path = File.expand_path(File.dirname(__FILE__) + '/fixtures/' + filename)
  File.read(file_path)
end

def createsend_url(auth_options, url)
  if not url =~ /^http/
    auth = ''
    auth = "#{auth_options[:api_key]}:x@" if auth_options[:api_key]
    result = "https://#{auth}api.createsend.com/api/v3/#{url}"
  else
    result = url
  end
  result
end

def stub_request(method, auth_options, url, filename, status=nil)
  # auth_options must be of the form: { :access_token => 'token', :api_key => 'key' }
  options = {:body => ""}
  options.merge!({:body => fixture_file(filename)}) if filename
  options.merge!({:status => status}) if status
  options.merge!(:content_type => "application/json; charset=utf-8")
  FakeWeb.register_uri(method, createsend_url(auth_options, url), options)
end

def stub_get(*args); stub_request(:get, *args) end
def stub_post(*args); stub_request(:post, *args) end
def stub_put(*args); stub_request(:put, *args) end
def stub_delete(*args); stub_request(:delete, *args) end

def multiple_contexts(*contexts, &blk)
  contexts.each do |context|
    send(context, &blk)# if respond_to?(context)
  end
end

def authenticated_using_oauth_context(&blk)
  context "when an api caller is authenticated using oauth" do
    setup do
      @access_token = 'joidjo2i3joi3je'
      @refresh_token = 'j89u98eu9e8ufe'
      @api_key = nil
      @auth_options = {:access_token => @access_token, :api_key => @api_key}
      @base_uri = 'https://api.createsend.com/api/v3'
      CreateSend.oauth @access_token, @refresh_token
    end
    merge_block(&blk)
  end
end

def authenticated_using_api_key_context(&blk)
  context "when an api caller is authenticated using an api key" do
    setup do
      @api_key = '123123123123123123123'
      @access_token = nil
      @refresh_token = nil
      @auth_options = {:access_token => @access_token, :api_key => @api_key}
      @base_uri = 'https://api.createsend.com/api/v3'
      CreateSend.api_key @api_key
    end
    merge_block(&blk)
  end
end
