module CreateSend
  # Represents an administrator and associated functionality.
  class Administrator < CreateSend
    attr_reader :email_address

    def initialize(auth, email_address)
      @email_address = email_address
      super
    end

    # Gets an administrator by email address.
    def self.get(auth, email_address)
      options = { :query => { :email => email_address } }
      cs = CreateSend.new auth
      response = cs.cs_get "/admins.json", options
      Hashie::Mash.new(response)
    end

    # Adds an administrator to the account.
    def self.add(auth, email_address, name)
      options = { :body => {
        :EmailAddress => email_address,
        :Name => name
      }.to_json }
      cs = CreateSend.new auth
      response = cs.cs_post "/admins.json", options
      Hashie::Mash.new(response)
    end

    # Updates the administator details.
    def update(new_email_address, name)
      options = {
        :query => { :email => @email_address },
        :body => {
          :EmailAddress => new_email_address,
          :Name => name
        }.to_json }
      put '/admins.json', options
      # Update @email_address, so this object can continue to be used reliably
      @email_address = new_email_address
    end

    # Deletes this administrator from the account.
    def delete
      options = { :query => { :email => @email_address } }
      super '/admins.json', options
    end
  end
end