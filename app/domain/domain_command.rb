# frozen_string_literal: true

class DomainCommand
  include ActiveModel::Model

  # attr_accessor :current_user

  def build_error_message
    errors.messages.map { |k, v| "#{k} #{v.join(' and ')}" }.join(", ")
  end

  def ensure_valid!
    # TODO ES use a domain exception that is configured to return bad_request
    # https://guides.rubyonrails.org/configuring.html
    # config.action_dispatch.rescue_responses
    raise ActionController::BadRequest, build_error_message unless valid?
  end
end