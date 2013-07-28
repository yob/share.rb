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
      log "#{@session.id[0,5]} C: #{message.inspect}"
      response = @session.handle_message(message)
      send_data response if response
    rescue Exception => e
      log "on_message_exception: #{e.inspect}"
      log e.backtrace.first
    end

    # Called by documents to notify other users of new operations. Response
    # should be a hash that follows the sharejs protocol. Something like:
    #
    #   response = {
    #      doc: "docid",
    #      v: 1,
    #      op: [{"i" => "foo", "p" => 0}],
    #    }
    #
    def on_operation(response)
      puts "#{@session.id[0,5]} WebSocketApp#on_operation #{response.inspect}"
      send_data response
    end

    private

    def send_data(message)
      log "#{@session.id[0,5]} S: #{message.inspect}"
      super JSON.dump(message)
    end

    def log(msg)
      puts msg
    end

  end
end
