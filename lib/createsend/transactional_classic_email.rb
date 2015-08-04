module CreateSend
  module Transactional
    class ClassicEmail < CreateSend
      attr_accessor :options

      def initialize(auth, client_id = nil)
        @auth = auth
        @client_id = client_id
        super
      end

      def send(options)
        response = post "/transactional/classicemail/send", { :body => options.to_json , :query => client_id }
        response.map{|item| Hashie::Mash.new(item)}
      end

      def groups
        response = get "/transactional/classicemail/groups", :query => client_id
        response.map{|item| Hashie::Mash.new(item)}
      end

      private

      def client_id
        {:clientID => @client_id} if @client_id
      end

    end
  end
end


