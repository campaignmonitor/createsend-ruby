require 'createsend'
require 'json'

module CreateSend
  # Represents an email template and associated functionality.
  class Template
    attr_reader :template_id

    def initialize(template_id)
      @template_id = template_id
    end

    # Creates a new email template.
    def self.create(client_id, name, html_url, zip_url)
      options = { :body => { 
        :Name => name,
        :HtmlPageURL => html_url,
        :ZipFileURL => zip_url }.to_json }
      response = CreateSend.post "/templates/#{client_id}.json", options
      response.parsed_response
    end

    # Gets the details of this email template.
    def details
      response = CreateSend.get "/templates/#{template_id}.json", {}
      Hashie::Mash.new(response)
    end

    # Updates this email template.
    def update(name, html_url, zip_url)
      options = { :body => { 
        :Name => name,
        :HtmlPageURL => html_url,
        :ZipFileURL => zip_url }.to_json }
      response = CreateSend.put "/templates/#{template_id}.json", options
    end

    # Deletes this email template.
    def delete
      response = CreateSend.delete "/templates/#{template_id}.json", {}
    end
  end
end