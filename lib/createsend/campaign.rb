module CreateSend
  # Represents a campaign and provides associated funtionality.
  class Campaign < CreateSend
    attr_reader :campaign_id

    def initialize(auth, campaign_id)
      @campaign_id = campaign_id
      super
    end

    # Creates a new campaign for a client.
    # client_id - String representing the ID of the client for whom the
    #   campaign will be created.
    # subject - String representing the subject of the campaign.
    # name - String representing the name of the campaign.
    # from_name - String representing the from name for the campaign.
    # from_email - String representing the from address for the campaign.
    # reply_to - String representing the reply-to address for the campaign.
    # html_url - String representing the URL for the campaign HTML content.
    # text_url - String representing the URL for the campaign text content.
    #  Note that text_url is optional and if nil or an empty string, text
    #  content will be automatically generated from the HTML content.
    # list_ids - Array of Strings representing the IDs of the lists to
    #   which the campaign will be sent.
    # segment_ids - Array of Strings representing the IDs of the segments to
    #   which the campaign will be sent.
    def self.create(auth, client_id, subject, name, from_name, from_email,
      reply_to, html_url, text_url, list_ids, segment_ids)
      options = { :body => {
        :Subject => subject,
        :Name => name,
        :FromName => from_name,
        :FromEmail => from_email,
        :ReplyTo => reply_to,
        :HtmlUrl => html_url,
        :TextUrl => text_url,
        :ListIDs => list_ids,
        :SegmentIDs => segment_ids }.to_json }
      cs = CreateSend.new auth
      response = cs.post "/campaigns/#{client_id}.json", options
      response.parsed_response
    end

    # Creates a new campaign for a client, from a template.
    # client_id - String representing the ID of the client for whom the
    #   campaign will be created.
    # subject - String representing the subject of the campaign.
    # name - String representing the name of the campaign.
    # from_name - String representing the from name for the campaign.
    # from_email - String representing the from address for the campaign.
    # reply_to - String representing the reply-to address for the campaign.
    # list_ids - Array of Strings representing the IDs of the lists to
    #   which the campaign will be sent.
    # segment_ids - Array of Strings representing the IDs of the segments to
    #   which the campaign will be sent.
    # template_id - String representing the ID of the template on which
    #   the campaign will be based.
    # template_content - Hash representing the content to be used for the
    #   editable areas of the template. See documentation at
    #   campaignmonitor.com/api/campaigns/#creating_a_campaign_from_template
    #   for full details of template content format.
    def self.create_from_template(auth, client_id, subject, name, from_name,
      from_email, reply_to, list_ids, segment_ids, template_id,
      template_content)
      options = { :body => {
        :Subject => subject,
        :Name => name,
        :FromName => from_name,
        :FromEmail => from_email,
        :ReplyTo => reply_to,
        :ListIDs => list_ids,
        :SegmentIDs => segment_ids,
        :TemplateID => template_id,
        :TemplateContent => template_content }.to_json }
      cs = CreateSend.new auth
      response = cs.post(
        "/campaigns/#{client_id}/fromtemplate.json", options)
      response.parsed_response
    end

    # Sends a preview of this campaign.
    def send_preview(recipients, personalize="fallback")
      options = { :body => {
        :PreviewRecipients => recipients.kind_of?(String) ?
          [ recipients ] : recipients,
        :Personalize => personalize }.to_json }
      post "sendpreview", options
    end

    # Sends this campaign.
    def send(confirmation_email, send_date="immediately")
      options = { :body => {
        :ConfirmationEmail => confirmation_email,
        :SendDate => send_date }.to_json }
      post "send", options
    end

    # Unschedules this campaign if it is currently scheduled.
    def unschedule
      options = { :body => "" }
      post "unschedule", options
    end

    # Deletes this campaign.
    def delete
      super "/campaigns/#{campaign_id}.json", {}
    end

    # Gets a summary of this campaign
    def summary
      response = get "summary", {}
      Hashie::Mash.new(response)
    end

    # Gets the email clients that subscribers used to open the campaign
    def email_client_usage
      response = get "emailclientusage", {}
      response.map{|item| Hashie::Mash.new(item)}
    end

    # Retrieves the lists and segments to which this campaaign will
    # be (or was) sent.
    def lists_and_segments
      response = get "listsandsegments", {}
      Hashie::Mash.new(response)
    end

    # Retrieves the recipients of this campaign.
    def recipients(page=1, page_size=1000, order_field="email",
      order_direction="asc")
      options = { :query => {
        :page => page,
        :pagesize => page_size,
        :orderfield => order_field,
        :orderdirection => order_direction } }
      response = get 'recipients', options
      Hashie::Mash.new(response)
    end

    # Retrieves the opens for this campaign.
    def opens(date="", page=1, page_size=1000, order_field="date",
      order_direction="asc")
      paged_result_by_date("opens", date, page, page_size, order_field,
        order_direction)
    end

    # Retrieves the subscriber clicks for this campaign.
    def clicks(date="", page=1, page_size=1000, order_field="date",
      order_direction="asc")
      paged_result_by_date("clicks", date, page, page_size, order_field,
        order_direction)
    end

    # Retrieves the unsubscribes for this campaign.
    def unsubscribes(date="", page=1, page_size=1000, order_field="date",
      order_direction="asc")
      paged_result_by_date("unsubscribes", date, page, page_size, order_field,
        order_direction)
    end

    # Retrieves the spam complaints for this campaign.
    def spam(date="", page=1, page_size=1000, order_field="date",
      order_direction="asc")
      paged_result_by_date("spam", date, page, page_size, order_field,
        order_direction)
    end

    # Retrieves the bounces for this campaign.
    def bounces(date="", page=1, page_size=1000, order_field="date",
      order_direction="asc")
      paged_result_by_date("bounces", date, page, page_size, order_field,
        order_direction)
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

    def uri_for(action)
      "/campaigns/#{campaign_id}/#{action}.json"
    end

  end
end