require 'createsend'
require 'json'

module CreateSend
  # Represents a subscriber list segment and associated functionality.
  class Segment
    attr_reader :segment_id, :active_subscribers, :rules, :list_id, :title

    def initialize(segment_id, api_key, with_details = false)
      @segment_id = segment_id
      @api_key = api_key
      @create_send = CreateSend.new(@api_key)
      details if with_details
    end

    # Creates a new segment.
    def self.create(list_id, title, rules, api_key)
      options = { :body => {
        :Title => title,
        :Rules => rules }.to_json }
      response = CreateSend.new(api_key).post "/segments/#{list_id}.json", options
      response.parsed_response
    end

    # Updates this segment.
    def update(title, rules)
      options = { :body => {
        :Title => title,
        :Rules => rules }.to_json }
      response = @create_send.put "/segments/#{segment_id}.json", options
    end

    # Adds a rule to this segment.
    def add_rule(subject, clauses)
      options = { :body => {
        :Subject => subject,
        :Clauses => clauses }.to_json }
      response = @create_send.post "/segments/#{segment_id}/rules.json", options
    end

    # Gets the active subscribers in this segment.
    def subscribers(date, page=1, page_size=1000, order_field="email", order_direction="asc")
      options = { :query => {
        :date => date,
        :page => page,
        :pagesize => page_size,
        :orderfield => order_field,
        :orderdirection => order_direction } }
      response = get "active", options
      Hashie::Mash.new(response)
    end

    # Gets the details of this segment
    def details
      response = @create_send.get "/segments/#{segment_id}.json", {}
      hash = Hashie::Mash.new(response)

      hash.each do |k,v|
        instance_variable_set :"@#{k.underscore}", v
      end

      hash
    end

    # Clears all rules of this segment.
    def clear_rules
      response = @create_send.delete "/segments/#{segment_id}/rules.json", {}
    end

    # Deletes this segment.
    def delete
      response = @create_send.delete "/segments/#{segment_id}.json", {}
    end

    private

    def get(action, options = {})
      @create_send.get uri_for(action), options
    end

    def post(action, options = {})
      @create_send.post uri_for(action), options
    end

    def put(action, options = {})
      @create_send.put uri_for(action), options
    end

    def uri_for(action)
      "/segments/#{segment_id}/#{action}.json"
    end

  end
end
