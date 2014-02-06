module CreateSend
  # Represents a subscriber list segment and associated functionality.
  class Segment < CreateSend
    attr_reader :segment_id

    def initialize(auth, segment_id)
      @segment_id = segment_id
      super
    end

    # Creates a new segment.
    def self.create(auth, list_id, title, rule_groups)
      options = { :body => {
        :Title => title,
        :RuleGroups => rule_groups }.to_json }
      cs = CreateSend.new auth
      response = cs.post "/segments/#{list_id}.json", options
      response.parsed_response
    end

    # Updates this segment.
    def update(title, rule_groups)
      options = { :body => {
        :Title => title,
        :RuleGroups => rule_groups }.to_json }
      cs_put "/segments/#{segment_id}.json", options
    end

    # Adds a rule to this segment.
    def add_rule_group(rule_group)
      options = { :body => {
        :Rules => rule_group }.to_json }
      post "rules", options
    end

    # Gets the active subscribers in this segment.
    def subscribers(date="", page=1, page_size=1000, order_field="email",
      order_direction="asc")
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
      response = cs_get "/segments/#{segment_id}.json", {}
      Hashie::Mash.new(response)
    end

    # Clears all rules of this segment.
    def clear_rules
      cs_delete "/segments/#{segment_id}/rules.json", {}
    end

    # Deletes this segment.
    def delete
      super "/segments/#{segment_id}.json", {}
    end

    private

    def get(action, options = {})
      super uri_for(action), options
    end

    def post(action, options = {})
      super uri_for(action), options
    end

    def uri_for(action)
      "/segments/#{segment_id}/#{action}.json"
    end

  end
end