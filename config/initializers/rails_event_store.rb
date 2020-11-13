# frozen_string_literal: true

require "rails_event_store"
require "aggregate_root"
require "arkency/command_bus"
require "arkency/command_bus/alias"

Rails.configuration.to_prepare do
  Rails.configuration.event_store = RailsEventStore::Client.new
  Rails.configuration.event_store.subscribe(
    IdeaDomain::Policies::WhenIdeaCreated.new,
    to: [IdeaDomain::Events::IdeaCreated],
  )
end
