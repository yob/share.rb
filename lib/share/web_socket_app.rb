require "rack/websocket"

class WebSocketError < StandardError; end

module Share
  class WebSocketApp < Rack::WebSocket::Application

    def initialize(repo)
      @repo = repo
      super({})
    end

    def subscribe_to(document_id, at_version)
      @repo.subscribe document_id, at_version, self
    end

    def unsubscribe_from(document_id)
      @repo.unsubscribe document_id
    end

    # Rack::WebSocket callback
    def on_open(env)
      @session = Share::Session.new(@repo)
      send_data @session.handshake_response
    end

    # Rack::WebSocket callback
    def on_close(env)

    end

    # Rack::WebSocket callback
    def on_message(env, raw_message)
      message = Message.new(raw_message)
      response = @protocol.handle_message(message)
      send_data response if response
    end

    # update via observable
    def on_operation(operation)
      return if operation[:meta] && operation[:meta]["source"] == @session.id
      send_data @protocol.message_for_operation(operation)        
    end

    private

    def send_data(message)
      super JSON.dump(message)
    end
  end
end
