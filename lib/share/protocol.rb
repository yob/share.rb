module Share
  class ProtocolError < ArgumentError; end

  class Protocol
    def initialize(app, repo, session)
      @app = app
      @repo = repo
      @session = session
      @current_document = nil
    end

  end
end
