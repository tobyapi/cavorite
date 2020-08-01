module Cavorite::Core
  class ActorRef
    @protocol : String
    @system : String
    @address : String
    @port : Int32
    @path : String

    getter path : String

    def initialize(@path : String)
      @protocol = "cavorite"
      @system = ""
      @address = "127.0.0.1"
      @port = 8080
    end

    def to_s
      "#{@protocol}://#{@system}@#{@address}:#{@port}/#{@path}"
    end
  end
end