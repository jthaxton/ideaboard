module IdeaDomain
  class Idea
    include AggregateRoot
    attr_accessor(
      :body,
      :id,
      :title
    )

    def initialize
    #   self.title = ''
    #   self.body = ''
    end

    def apply_idea_created(event)
      binding.pry
      self.id = event.data[:id]
      self.title = event.data[:title]
      self.body = event.data[:body]
    end
  end
end