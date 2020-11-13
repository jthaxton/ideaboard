# frozen_string_literal: true

module IdeaDomain
  module Events
    class IdeaCreated < ::RailsEventStore::Event
      attr_accessor :data
    end
  end
end
