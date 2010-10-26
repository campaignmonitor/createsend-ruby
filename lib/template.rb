require 'createsend'
require 'json'

class Template
  attr_reader :template_id

  def initialize(template_id)
    @template_id = template_id
  end

  def self.create(client_id, name, html_url, zip_url, screenshot_url)
    options = { :body => { 
      :Name => name,
      :HtmlPageURL => html_url,
      :ZipFileURL => zip_url,
      :ScreenshotURL => screenshot_url }.to_json }
    response = CreateSend.post "/templates/#{client_id}.json", options
    response.parsed_response
  end

  def details
    response = CreateSend.get "/templates/#{template_id}.json", {}
    Hashie::Mash.new(response)
  end

  def update(name, html_url, zip_url, screenshot_url)
    options = { :body => { 
      :Name => name,
      :HtmlPageURL => html_url,
      :ZipFileURL => zip_url,
      :ScreenshotURL => screenshot_url }.to_json }
    response = CreateSend.put "/templates/#{template_id}.json", options
  end

  def delete
    response = CreateSend.delete "/templates/#{template_id}.json", {}
  end
end