module CreateSend
  # Represents an email template and associated functionality.
  class Template < CreateSend
    attr_reader :template_id

    def initialize(auth, template_id)
      @template_id = template_id
      super
    end

    # Creates a new email template.
    def self.create(auth, client_id, name, html_url, zip_url)
      options = { :body => {
        :Name => name,
        :HtmlPageURL => html_url,
        :ZipFileURL => zip_url }.to_json }
      cs = CreateSend.new auth
      response = cs.post "/templates/#{client_id}.json", options
      response.parsed_response
    end

    # Gets the details of this email template.
    def details
      response = get "/templates/#{template_id}.json", {}
      Hashie::Mash.new(response)
    end

    # Updates this email template.
    def update(name, html_url, zip_url)
      options = { :body => {
        :Name => name,
        :HtmlPageURL => html_url,
        :ZipFileURL => zip_url }.to_json }
      put "/templates/#{template_id}.json", options
    end

    # Deletes this email template.
    def delete
      super "/templates/#{template_id}.json", {}
    end
  end
end