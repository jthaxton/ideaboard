# frozen_string_literal: true

module IdeaDomain
  module Handlers
    class OnCreateIdea
      def self.register(config)
        config.command_bus.register(IdeaDomain::Commands::CreateIdea, self)
      end

      def self.call(command)
        # add more command validation here
        binding.pry
        idea_repository.with_idea(command.id) do |idea|
          binding.pry
          event = build_idea_created_event(command)
          idea.apply(event)
        end
      end


      def self.idea_repository
        Rails.configuration.idea_repository
      end

      def self.build_idea_created_event(command)
        Events::IdeaCreated.build(
          title: command.title,
          body: command.body,
          id: command.id.to_i
        )
      end
    end
  end
end