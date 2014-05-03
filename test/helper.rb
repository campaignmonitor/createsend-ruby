require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start

require 'test/unit'
require 'pathname'

require 'shoulda/context'
require 'matchy'
require 'fakeweb'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'createsend'

FakeWeb.allow_net_connect = %r[^https?://coveralls.io]

def fixture_file(filename)
  return '' if filename == ''
  file_path = File.expand_path(File.dirname(__FILE__) + '/fixtures/' + filename)
  File.read(file_path)
end

def createsend_url(auth, url)
  if not url =~ /^http/
    auth_section = ''
    auth_section = "#{auth[:api_key]}:x@" if auth and auth.has_key? :api_key
    result = "https://#{auth_section}api.createsend.com/api/v3.1/#{url}"
  else
    result = url
  end
  result
end

def stub_request(method, auth, url, filename, status=nil)
  options = {:body => ""}
  options.merge!({:body => fixture_file(filename)}) if filename
  options.merge!({:status => status}) if status
  options.merge!(:content_type => "application/json; charset=utf-8")
  FakeWeb.register_uri(method, createsend_url(auth, url), options)
end

def stub_get(*args); stub_request(:get, *args) end
def stub_post(*args); stub_request(:post, *args) end
def stub_put(*args); stub_request(:put, *args) end
def stub_delete(*args); stub_request(:delete, *args) end

def multiple_contexts(*contexts, &blk)
  contexts.each do |context|
    send(context, &blk)
  end
end

def authenticated_using_oauth_context(&blk)
  context "when an api caller is authenticated using oauth" do
    setup do
      @access_token = 'joidjo2i3joi3je'
      @refresh_token = 'j89u98eu9e8ufe'
      @auth = {:access_token => @access_token, :refresh_token => @refresh_token}
    end
    merge_block(&blk)
  end
end

def authenticated_using_api_key_context(&blk)
  context "when an api caller is authenticated using an api key" do
    setup do
      @api_key = '123123123123123123123'
      @auth = {:api_key => @api_key}
    end
    merge_block(&blk)
  end
end
