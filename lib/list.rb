require 'createsend'
require 'json'

class List
  attr_reader :list_id

  def initialize(list_id)
    @list_id = list_id
  end

  def self.create(client_id, title, unsubscribe_page, confirmed_opt_in, confirmation_success_page)
    options = { :body => {
      :Title => title,
      :UnsubscribePage => unsubscribe_page,
      :ConfirmedOptIn => confirmed_opt_in,
      :ConfirmationSuccessPage => confirmation_success_page }.to_json }
    response = CreateSend.post "/lists/#{client_id}.json", options
    response.parsed_response
  end

  def delete
    response = CreateSend.delete "/lists/#{list_id}.json", {}
  end
  
  def create_custom_field(field_name, data_type, options=[])
    options = { :body => {
      :FieldName => field_name,
      :DataType => data_type,
      :Options => options }.to_json }
    response = post "customfields", options
    response.parsed_response
  end

  def delete_custom_field(custom_field_key)
    custom_field_key = CGI.escape(custom_field_key)
    response = CreateSend.delete "/lists/#{list_id}/customfields/#{custom_field_key}.json", {}
  end
  
  def details
    response = CreateSend.get "/lists/#{list_id}.json", {}
    Hashie::Mash.new(response)
  end
  
  def custom_fields
    response = get "customfields"
    response.map{|item| Hashie::Mash.new(item)}
  end

  def segments
    response = get "segments"
    response.map{|item| Hashie::Mash.new(item)}
  end

  def segment_subscribers(segment_id, date, page=1, page_size=1000, order_field="email", order_direction="asc")
    options = { :query => {
      :date => date,
      :page => page,
      :pagesize => page_size,
      :orderfield => order_field,
      :orderdirection => order_direction } }
    response = get "segments/#{segment_id}/active", options
    Hashie::Mash.new(response)
  end
  
  def stats
    response = get "stats"
    Hashie::Mash.new(response)
  end

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