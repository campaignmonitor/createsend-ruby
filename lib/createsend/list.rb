module CreateSend
  # Represents a subscriber list and associated functionality.
  class List < CreateSend
    attr_reader :list_id

    def initialize(auth, list_id)
      @list_id = list_id
      super
    end

    # Creates a new list for a client.
    # client_id - String representing the ID of the client for whom the list
    #   will be created
    # title - String representing the list title/name
    # unsubscribe_page - String representing the url of the unsubscribe
    #   confirmation page
    # confirmed_opt_in - A Boolean representing whether this should be a
    #   confirmed opt-in (double opt-in) list
    # confirmation_success_page - String representing the url of the
    #   confirmation success page
    # unsubscribe_setting - A String which must be either "AllClientLists" or
    #   "OnlyThisList". See the documentation for details:
    #   http://www.campaignmonitor.com/api/lists/#creating_a_list
    def self.create(auth, client_id, title, unsubscribe_page, confirmed_opt_in,
      confirmation_success_page, unsubscribe_setting="AllClientLists")
      options = { :body => {
        :Title => title,
        :UnsubscribePage => unsubscribe_page,
        :ConfirmedOptIn => confirmed_opt_in,
        :ConfirmationSuccessPage => confirmation_success_page,
        :UnsubscribeSetting => unsubscribe_setting }.to_json }
      cs = CreateSend.new auth
      response = cs.post "/lists/#{client_id}.json", options
      response.parsed_response
    end

    # Deletes this list.
    def delete
      super "/lists/#{list_id}.json", {}
    end

    # Creates a new custom field for this list.
    # field_name - String representing the name to be given to the field
    # data_type - String representing the data type of the field. Valid data
    #   types are 'Text', 'Number', 'MultiSelectOne', 'MultiSelectMany',
    #   'Date', 'Country', and 'USState'.
    # options - Array of Strings representing the options for the field if it
    #   is of type 'MultiSelectOne' or 'MultiSelectMany'.
    # visible_in_preference_center - Boolean indicating whether or not the
    #    field should be visible in the subscriber preference center
    def create_custom_field(field_name, data_type, options=[],
      visible_in_preference_center=true)
      options = { :body => {
        :FieldName => field_name,
        :DataType => data_type,
        :Options => options,
        :VisibleInPreferenceCenter => visible_in_preference_center }.to_json }
      response = post "customfields", options
      response.parsed_response
    end

    # Updates a custom field belonging to this list.
    # custom_field_key - String which represents the key for the custom field
    # field_name - String representing the name to be given to the field
    # visible_in_preference_center - Boolean indicating whether or not the
    #    field should be visible in the subscriber preference center
    def update_custom_field(custom_field_key, field_name,
      visible_in_preference_center)
      custom_field_key = CGI.escape(custom_field_key)
      options = { :body => {
        :FieldName => field_name,
        :VisibleInPreferenceCenter => visible_in_preference_center }.to_json }
      response = put "customfields/#{custom_field_key}", options
      response.parsed_response
    end

    # Deletes a custom field associated with this list.
    def delete_custom_field(custom_field_key)
      custom_field_key = CGI.escape(custom_field_key)
      cs_delete("/lists/#{list_id}/customfields/#{custom_field_key}.json", {})
    end

    # Updates the options of a multi-optioned custom field on this list.
    def update_custom_field_options(custom_field_key, new_options,
      keep_existing_options)
      custom_field_key = CGI.escape(custom_field_key)
      options = { :body => {
        :Options => new_options,
        :KeepExistingOptions => keep_existing_options }.to_json }
      put "customfields/#{custom_field_key}/options", options
    end

    # Gets the details of this list.
    def details
      response = cs_get "/lists/#{list_id}.json"
      Hashie::Mash.new(response)
    end

    # Gets the custom fields for this list.
    def custom_fields
      response = get "customfields"
      response.map{|item| Hashie::Mash.new(item)}
    end

    # Gets the segments for this list.
    def segments
      response = get "segments"
      response.map{|item| Hashie::Mash.new(item)}
    end

    # Gets the stats for this list.
    def stats
      response = get "stats"
      Hashie::Mash.new(response)
    end

    # Gets the active subscribers for this list.
    def active(date="", page=1, page_size=1000, order_field="email",
      order_direction="asc")
      paged_result_by_date("active", date, page, page_size, order_field,
        order_direction)
    end

    # Gets the unconfirmed subscribers for this list.
    def unconfirmed(date="", page=1, page_size=1000, order_field="email",
      order_direction="asc")
      paged_result_by_date("unconfirmed", date, page, page_size, order_field,
        order_direction)
    end

    # Gets the bounced subscribers for this list.
    def bounced(date="", page=1, page_size=1000, order_field="email",
      order_direction="asc")
      paged_result_by_date("bounced", date, page, page_size, order_field,
        order_direction)
    end

    # Gets the unsubscribed subscribers for this list.
    def unsubscribed(date="", page=1, page_size=1000, order_field="email",
      order_direction="asc")
      paged_result_by_date("unsubscribed", date, page, page_size, order_field,
        order_direction)
    end

    # Gets the deleted subscribers for this list.
    def deleted(date="", page=1, page_size=1000, order_field="email",
      order_direction="asc")
      paged_result_by_date("deleted", date, page, page_size, order_field,
        order_direction)
    end

    # Updates this list.
    # title - String representing the list title/name
    # unsubscribe_page - String representing the url of the unsubscribe
    #   confirmation page
    # confirmed_opt_in - A Boolean representing whether this should be a
    #   confirmed opt-in (double opt-in) list
    # confirmation_success_page - String representing the url of the
    #   confirmation success page
    # unsubscribe_setting - A String which must be either "AllClientLists" or
    #   "OnlyThisList". See the documentation for details:
    #   http://www.campaignmonitor.com/api/lists/#updating_a_list
    # add_unsubscribes_to_supp_list - When unsubscribe_setting is
    #   "AllClientLists", a Boolean which represents whether unsubscribes from
    #   this list should be added to the suppression list
    # scrub_active_with_supp_list - When unsubscribe_setting is
    #   "AllClientLists", a Boolean which represents whether active sunscribers
    #   should be scrubbed against the suppression list
    def update(title, unsubscribe_page, confirmed_opt_in,
      confirmation_success_page, unsubscribe_setting="AllClientLists",
      add_unsubscribes_to_supp_list=false, scrub_active_with_supp_list=false)
      options = { :body => {
        :Title => title,
        :UnsubscribePage => unsubscribe_page,
        :ConfirmedOptIn => confirmed_opt_in,
        :ConfirmationSuccessPage => confirmation_success_page,
        :UnsubscribeSetting => unsubscribe_setting,
        :AddUnsubscribesToSuppList => add_unsubscribes_to_supp_list,
        :ScrubActiveWithSuppList => scrub_active_with_supp_list }.to_json }
      cs_put "/lists/#{list_id}.json", options
    end

    # Gets the webhooks for this list.
    def webhooks
      response = get "webhooks"
      response.map{|item| Hashie::Mash.new(item)}
    end

    # Creates a new webhook for the specified events (an array of strings).
    # Valid events are "Subscribe", "Deactivate", and "Update".
    # Valid payload formats are "json", and "xml".
    def create_webhook(events, url, payload_format)
      options = { :body => {
        :Events => events,
        :Url => url,
        :PayloadFormat => payload_format }.to_json }
      response = post "webhooks", options
      response.parsed_response
    end

    # Tests that a post can be made to the endpoint specified for the webhook
    # identified by webhook_id.
    def test_webhook(webhook_id)
      get "webhooks/#{webhook_id}/test"
      true # An exception will be raised if any error occurs
    end

    # Deletes a webhook associated with this list.
    def delete_webhook(webhook_id)
      cs_delete("/lists/#{list_id}/webhooks/#{webhook_id}.json", {})
    end

    # Activates a webhook associated with this list.
    def activate_webhook(webhook_id)
      options = { :body => '' }
      put "webhooks/#{webhook_id}/activate", options
    end

    # De-activates a webhook associated with this list.
    def deactivate_webhook(webhook_id)
      options = { :body => '' }
      put "webhooks/#{webhook_id}/deactivate", options
    end

    private
    
    def paged_result_by_date(resource, date, page, page_size, order_field,
      order_direction)
      options = { :query => {
        :date => date,
        :page => page,
        :pagesize => page_size,
        :orderfield => order_field,
        :orderdirection => order_direction } }
      response = get resource, options
      Hashie::Mash.new(response)
    end

    def get(action, options = {})
      super uri_for(action), options
    end

    def post(action, options = {})
      super uri_for(action), options
    end

    def put(action, options = {})
      super uri_for(action), options
    end

    def uri_for(action)
      "/lists/#{list_id}/#{action}.json"
    end

  end
end