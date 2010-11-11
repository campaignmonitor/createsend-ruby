require 'createsend'
require 'json'

# Represents a subscriber list segment and associated functionality.
class Segment
  attr_reader :segment_id

  def initialize(segment_id)
    @segment_id = segment_id
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

  # Clears all rules of this segment.
  def clear_rules
    response = CreateSend.delete "/segments/#{segment_id}/rules.json", {}
  end

  # Deletes this segment.
  def delete
    response = CreateSend.delete "/segments/#{segment_id}.json", {}
  end
  
  private

  def get(action, options = {})
    CreateSend.get uri_for(action), options
  end

  def post(action, options = {})
    CreateSend.post uri_for(action), options
  end

  def put(action, options = {})
    CreateSend.put uri_for(action), options
  end

  def uri_for(action)
    "/segments/#{segment_id}/#{action}.json"
  end

end