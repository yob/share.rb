require 'browser_channel'

module Share
  class BcApp < BrowserChannel::App

    def initialize(repo)
      @repo = repo
      super({})
    end

    def on_message(raw_message)
      log "on_message: #{raw_message.inspect}"
    end

    private

    def log(msg)
      puts msg
    end
  end
end

