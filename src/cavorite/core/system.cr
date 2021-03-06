require "http/server"

require "./supervisor"

module Cavorite::Core
  class System
    @@systems = {} of String => System

    @name : String
    @root_guardian : Supervisor
    @user_guardian : Supervisor
    @system_guardian : Supervisor

    def initialize(@name : String)
      @root_guardian = Supervisor.new("root_guardian", Supervisor::Strategy::OneForOne)
      @user_guardian = Supervisor.new("user_guardian", Supervisor::Strategy::OneForOne)
      @system_guardian = Supervisor.new("system_guardian", Supervisor::Strategy::OneForOne)
      @@systems[@name] = self
    end

    def create(path : String, actor_name : String, actor_type : Actor.class)
      actor = actor_type.new(actor_name)
      add(path, actor)
    end

    def add(path : String, actor : ActorMarker) : ActorRef?
      current_actor = @user_guardian
      path.lchop('/').split('/').each do |child_name|
        break if child_name.empty?
        current_actor = current_actor.children[child_name]?
        return nil unless current_actor.is_a?(Supervisor)
      end
      current_actor.add_child(actor)
      ActorRef.new(@name, "#{path}/#{actor.name}")
    end

    def self.send!(actor_ref : ActorRef, msg : ActorMessage)
      actor = get(actor_ref)
      return nil if actor.nil?
      actor.send!(msg)
    end

    private def self.get(actor_ref : ActorRef)
      result = @@systems[actor_ref.system].@user_guardian
      # TODO: validate actor_ref.path
      actor_ref.path.lchop('/').split('/').each do |child_name|
        return nil if !result.is_a?(Supervisor)
        result = result.children[child_name]?
      end
      return nil if result.nil?
      result
    end
  end
end
