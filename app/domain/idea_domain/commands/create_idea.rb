module IdeaDomain
  module Commands
    class CreateIdea < DomainCommand
      attr_accessor(
        :body,
        :title,
        :id
      )
    end
  end
end