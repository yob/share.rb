require "thread_safe"

module Share
  class Repo

    class DocExistsError < ArgumentError; end
    class UnsupportedTypeError < ArgumentError; end

    def initialize
      @documents = ThreadSafe::Hash.new
    end

    def get(document_id)
      @documents[document_id] # || load from DB
    end

    def create(id, type)
      if get(id).nil?
        @documents[id] = Share::Document.new(id, type_string_to_instance(type))
      else
        raise DocExistsError, "doc #{id} already exists"
      end
    end

    private

    def type_string_to_instance(str)
      case str
      when "text" then Share::Types::Text.new
      else
        raise UnsupportedTypeError, "Unsupported type '#{str}'"
      end
    end

  end
end
