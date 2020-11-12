# frozen_string_literal: true

module IdeaDomain
  class IdeaRepository
    def self.build_stream_name(id)
      "IdeaDomain::Ideas$#{id}"
    end

    def initialize(repository = Rails.configuration.repository)
      self.repository = repository
    end

    def save(idea)
      repository.store(idea, self.class.build_stream_name(idea.id))
    end

    def find(id)
      repository.load(IdeaDomain::Idea.new, self.class.build_stream_name(id))
    end

    def with_idea(idea_id, &block)
      binding.pry
      repository.with_aggregate(IdeaDomain::Idea.new, self.class.build_stream_name(idea_id), &block)
    end

    private

    attr_accessor :repository
  end
end
