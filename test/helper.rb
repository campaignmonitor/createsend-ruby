require 'test/unit'
require 'pathname'

require 'shoulda'
require 'matchy'
require 'mocha'
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

def createsend_url(api_key, url)
  api_key.nil? ? url : url =~ /^http/ ? url : "https://#{api_key}:x@api.createsend.com/api/v3/#{url}"
end

def stub_request(method, api_key, url, filename, status=nil)
  options = {:body => ""}
  options.merge!({:body => fixture_file(filename)}) if filename
  options.merge!({:status => status}) if status
  options.merge!(:content_type => "application/json; charset=utf-8")
  FakeWeb.register_uri(method, createsend_url(api_key, url), options)
end

def stub_get(*args); stub_request(:get, *args) end
def stub_post(*args); stub_request(:post, *args) end
def stub_put(*args); stub_request(:put, *args) end
def stub_delete(*args); stub_request(:delete, *args) end
