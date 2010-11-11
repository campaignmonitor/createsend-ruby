require 'createsend'
require 'json'

# Represents a subscriber list and associated functionality.
class List
  attr_reader :list_id

  def initialize(list_id)
    @list_id = list_id
  end

  # Creates a new list for a client.
  def self.create(client_id, title, unsubscribe_page, confirmed_opt_in, confirmation_success_page)
    options = { :body => {
      :Title => title,
      :UnsubscribePage => unsubscribe_page,
      :ConfirmedOptIn => confirmed_opt_in,
      :ConfirmationSuccessPage => confirmation_success_page }.to_json }
    response = CreateSend.post "/lists/#{client_id}.json", options
    response.parsed_response
  end

  # Deletes this list.
  def delete
    response = CreateSend.delete "/lists/#{list_id}.json", {}
  end

  # Creates a new custom field for this list.
  def create_custom_field(field_name, data_type, options=[])
    options = { :body => {
      :FieldName => field_name,
      :DataType => data_type,
      :Options => options }.to_json }
    response = post "customfields", options
    response.parsed_response
  end

  # Deletes a custom field associated with this list.
  def delete_custom_field(custom_field_key)
    custom_field_key = CGI.escape(custom_field_key)
    response = CreateSend.delete "/lists/#{list_id}/customfields/#{custom_field_key}.json", {}
  end

  # Gets the details of this list.
  def details
    response = CreateSend.get "/lists/#{list_id}.json", {}
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
  def active(date, page=1, page_size=1000, order_field="email", order_direction="asc")
    options = { :query => { 
      :date => date,
      :page => page,
      :pagesize => page_size,
      :orderfield => order_field,
      :orderdirection => order_direction } }
    response = get "active", options
    Hashie::Mash.new(response)
  end

  # Gets the bounced subscribers for this list.
  def bounced(date, page=1, page_size=1000, order_field="email", order_direction="asc")
    options = { :query => { 
      :date => date,
      :page => page,
      :pagesize => page_size,
      :orderfield => order_field,
      :orderdirection => order_direction } }
    response = get "bounced", options
    Hashie::Mash.new(response)
  end

  # Gets the unsubscribed subscribers for this list.
  def unsubscribed(date, page=1, page_size=1000, order_field="email", order_direction="asc")
    options = { :query => { 
      :date => date,
      :page => page,
      :pagesize => page_size,
      :orderfield => order_field,
      :orderdirection => order_direction } }
    response = get "unsubscribed", options
    Hashie::Mash.new(response)
  end

  # Updates this list.
  def update(title, unsubscribe_page, confirmed_opt_in, confirmation_success_page)
    options = { :body => {
      :Title => title,
      :UnsubscribePage => unsubscribe_page,
      :ConfirmedOptIn => confirmed_opt_in,
      :ConfirmationSuccessPage => confirmation_success_page }.to_json }
    response = CreateSend.put "/lists/#{list_id}.json", options
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
    "/lists/#{list_id}/#{action}.json"
  end

end