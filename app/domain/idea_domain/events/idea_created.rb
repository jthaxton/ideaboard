# frozen_string_literal: true

module IdeaDomain
  module Events
    class IdeaCreated < DomainEvent
      SCHEMA = {
        title: String,
        body: String,
        id: Integer
      }.freeze

      def self.build(data)
        ClassyHash.validate(data, SCHEMA, strict: true, verbose: true)
        new(data: data)
      end
    end
  end
end
