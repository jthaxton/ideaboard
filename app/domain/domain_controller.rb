# frozen_string_literal: true

require "action_controller"

module DomainController
  extend ActiveSupport::Concern

  def call(command)
    # command.current_user = current_user if respond_to?(:current_user) && command.respond_to?(:current_user=)
    command.ensure_valid!
    Rails.configuration.command_bus.call(command)
  end

  def call_with(command_type)
    call(build(command_type))
  end

  def command_params
    params.except(
      :_method,
      :action,
      :authenticity_token,
      :client_id,
      :command,
      :commit,
      :controller,
      :'g-recaptcha-response',
      :utf8,
      :person_id,
    ).permit!
  end

  def build(command_type)
    command_type.new(command_params)
  end

  included do
    wrap_parameters :command

    rescue_from ActiveModel::UnknownAttributeError do |exception|
      raise(ActionController::BadRequest, exception.message)
    end
  end
end
