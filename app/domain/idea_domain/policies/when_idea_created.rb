module IdeaDomain
  module Policies
    class WhenIdeaCreated

      def call(event)
        binding.pry
        ::Idea.create(event.data)
      end

    end
  end
end
