# frozen_string_literal: true

require "rails_event_store"
require "aggregate_root"
require "arkency/command_bus"
require "arkency/command_bus/alias"

class InstrumentedCommandBus
  def initialize(target = CommandBus.new, instrumentation = ActiveSupport::Notifications)
    self.target = target
    self.instrumentation = instrumentation
  end

  delegate :register, to: :target

  def call(command)
    instrumentation.instrument("call.command_bus", command: command) do
      target.call(command)
    end
  end

  private

  attr_accessor :target, :instrumentation
end

def build_request_metadata(env, request)
  metadata = {}

  metadata[:correlation_id] = request.uuid
  metadata[:causation_id] = request.uuid
  metadata[:remote_ip] = request.remote_ip
  metadata[:request_id] = request.uuid

  # session = env["rack.session"]

  # metadata[:user_id] = session[:user_id] if session[:user_id]
  # metadata[:delegate_user_id] = session[:admin_id] if session[:admin_id]

  metadata
end

def request_metadata
  lambda do |env|
    build_request_metadata(env, ActionDispatch::Request.new(env))
  end
end

def rails_event_store_to_prepare(config)
  config.command_bus = InstrumentedCommandBus.new

  config.event_store = RailsEventStore::Client.new(
    mapper: RubyEventStore::Mappers::JSONMapper.new,
    # request_metadata: request_metadata
  )

  config.event_store.subscribe_to_all_events(RailsEventStore::LinkByCausationId.new)
  config.event_store.subscribe_to_all_events(RailsEventStore::LinkByCorrelationId.new)
  config.event_store.subscribe_to_all_events(RailsEventStore::LinkByEventType.new)

  config.repository = DomainRepository.new(config.event_store)
end

Rails.configuration.tap do |config|
  config.to_prepare do
    rails_event_store_to_prepare(config)
    # DOMAIN INITIALIZERS GO HERE
    # Domain::Initializer.to_prepare(config)
    IdeaDomain::Initializer.to_prepare(config)
  end
end
