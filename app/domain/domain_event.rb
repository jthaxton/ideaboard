# frozen_string_literal: true

class DomainEvent < RailsEventStore::Event
  def data
    ActiveSupport::HashWithIndifferentAccess.new(super)
  end
end
