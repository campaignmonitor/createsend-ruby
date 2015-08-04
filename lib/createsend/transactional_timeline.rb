module CreateSend
  module Transactional
    class Timeline < CreateSend
      attr_reader :client_id

      def initialize(auth, client_id = nil)
        @auth      = auth
        @client_id = client_id
        super
      end

      def messages(options = {})
        options = add_client_id(options)
        response = get "/transactional/messages", { :query => options }
        response.map{|item| Hashie::Mash.new(item)}
      end

      def statistics(options = {})
        options = add_client_id(options)
        response = get "/transactional/statistics", { :query => options }
        Hashie::Mash.new(response)
      end

      def details(message_id, options = {})
        options = add_client_id(options)
        response = get "/transactional/messages/#{message_id}", { :query => options }
        Hashie::Mash.new(response)
      end

      def resend(message_id)
        response = post "/transactional/messages/#{message_id}/resend"
        response.map{|item| Hashie::Mash.new(item)}
      end

      private

      def add_client_id(options)
        options['clientID'] = @client_id if @client_id
        options
      end

    end
  end
end

