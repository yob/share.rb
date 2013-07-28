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
      @session = Share::Session.new(@repo, self)
      send_data @session.handshake_response
    rescue Exception => e
      log "on_open_exception: #{e.inspect}"
    end

    # Rack::WebSocket callback
    def on_close(env)

    end

    # Rack::WebSocket callback
    def on_message(env, raw_message)
      message = Message.new(raw_message)
      log "C: #{message.inspect}"
      response = @session.handle_message(message)
      send_data response if response
    rescue Exception => e
      log "on_message_exception: #{e.inspect}"
    end

    # Call by documents to notify other users of new operations
    #
    def on_operation(operation)
      send_data @protocol.message_for_operation(operation)
    end

    private

    def send_data(message)
      log "S: #{message.inspect}"
      super JSON.dump(message)
    end

    def log(msg)
      puts msg
    end

  end
end
