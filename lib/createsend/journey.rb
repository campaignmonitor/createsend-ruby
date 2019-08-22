module CreateSend
  # Represents a journey and provides associated functionality
  class Journey < CreateSend
    attr_reader :journey_id

    def initialize(auth, journey_id)
      @journey_id = journey_id
      super
    end

    # Get a full summary of a journey
    def summary
      response = get "/journeys/#{@journey_id}.json"
      Hashie::Mash.new(response)
    end

    # Gets a list of all recipients of a particular email within a journey
    def email_recipients(email_id="", date="", page=1, page_size=1000, order_direction='asc')
      paged_result_by_date("recipients", email_id, date, page, page_size, order_direction)
    end

    # Gets a paged list of subscribers who opened a given journey email
    def email_opens(email_id="", date="", page=1, page_size=1000, order_direction='asc')
      paged_result_by_date("opens", email_id, date, page, page_size, order_direction)
    end

    # Gets a paged list of subscribers who clicked a given journey email
    def email_clicks(email_id="", date="", page=1, page_size=1000, order_direction='asc')
      paged_result_by_date("clicks", email_id, date, page, page_size, order_direction)
    end

    # Gets a paged result representing all subscribers who unsubscribed from a journey email
    def email_unsubscribes(email_id="", date="", page=1, page_size=1000, order_direction='asc')
      paged_result_by_date("unsubscribes", email_id, date, page, page_size, order_direction)
    end

    # Gets a paged result of all bounces for a journey email
    def email_bounces(email_id="", date="", page=1, page_size=1000, order_direction='asc')
      paged_result_by_date("bounces", email_id, date, page, page_size, order_direction)
    end

    private

    def paged_result_by_date(resource, email_id, date, page, page_size, order_direction)
      options = { :query => {
          :date => date,
          :page => page,
          :pagesize => page_size,
          :orderdirection => order_direction } }
      response = get_journey_email_action email_id, resource, options
      Hashie::Mash.new(response)
    end

    def get_journey_email_action(email_id, action, options = {})
      get "/journeys/email/#{email_id}/#{action}.json", options
    end
  end
end