module IdeaDomain
  class Initializer
    REGISTERABLE_HANDLERS = [
      IdeaDomain::Handlers::OnCreateIdea
    ].freeze

    def self.register(config)
      register_handlers(REGISTERABLE_HANDLERS, config)
    end

    def self.register_handlers(handlers, config)
      handlers.each do |handler|
        handler.register(config)
      end
    end

    def self.to_prepare(config)
      binding.pry
      config.idea_repository = IdeaDomain::IdeaRepository.new

      register(config)
      # subscribe(config)
    end
  end
end