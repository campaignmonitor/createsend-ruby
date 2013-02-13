module CreateSend
  # Represents a person and associated functionality.
  class Person < CreateSend
    attr_reader :client_id
    attr_reader :email_address

    def initialize(auth, client_id, email_address)
      @client_id = client_id
      @email_address = email_address
      super
    end

    # Gets a person by client ID and email address.
    def self.get(auth, client_id, email_address)
      options = { :query => { :email => email_address } }
      cs = CreateSend.new auth
      response = cs.get "/clients/#{client_id}/people.json", options
      Hashie::Mash.new(response)
    end

    # Adds a person to the client. Password is optional. If ommitted, an
    # email invitation will be sent to the person
    def self.add(auth, client_id, email_address, name, access_level, password)
      options = { :body => {
        :EmailAddress => email_address,
        :Name => name,
        :AccessLevel => access_level,
        :Password => password }.to_json }
      cs = CreateSend.new auth
      response = cs.post "/clients/#{client_id}/people.json", options
      Hashie::Mash.new(response)
    end

    # Updates the person details. password is optional and will only be
    # updated if supplied
    def update(new_email_address, name, access_level, password)
      options = {
        :query => { :email => @email_address },
        :body => {
          :EmailAddress => new_email_address,
          :Name => name,
          :AccessLevel => access_level,
          :Password => password }.to_json }
      put uri_for(client_id), options
      # Update @email_address, so this object can continue to be used reliably
      @email_address = new_email_address
    end

    # deletes this person from the client
    def delete
      options = { :query => { :email => @email_address } }
      super uri_for(client_id), options
    end

    def uri_for(client_id)
      "/clients/#{client_id}/people.json"
    end
  end
end