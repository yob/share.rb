require "thread_safe"

module Share
  # A collection of documents.
  class Repo

    class DocExistsError < ArgumentError; end

    def initialize
      @documents = ThreadSafe::Hash.new
    end

    def get(document_id)
      @documents[document_id] # || load from DB
    end

    def create(id, type)
      if get(id).nil?
        @documents[id] = Share::Document.new(id, type)
      else
        raise DocExistsError, "doc #{id} already exists"
      end
    end

  end
end
