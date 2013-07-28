module Share
  class ProtocolError < ArgumentError; end

  class Protocol
    def initialize(app, repo, session)
      @app = app
      @repo = repo
      @session = session
      @current_document = nil
    end

    def message_for_operation(operation)
      {
        doc: @current_document,
        v: operation[:v],
        op: operation[:op],
        meta: operation[:meta]
      }
    end

    def handshake
      {auth: @session.id}
    end
  end
end
