class ErrorsController < ApplicationController
  layout 'informations'

  def not_found
    render status: 404
  end

  def internal_server_error
    return unless Rails.env.production?
    begin
      server_name      = request.env["SERVER_NAME"]
      method           = request.method
      url              = request.url
      parameters       = request.parameters
      ip               = request.ip
      responsible_type = current_agent ? "Agent" : "User"
      responsible_id   = current_agent.try(:id) || current_user.try(:id)
      exception        = request.env['action_dispatch.exception']

      if exception.present?
        error_message  = exception.message.to_s
        backtrace      = exception.backtrace[0..4].join("\n")

        SlackNotifyJob.perform_later(server_name, method, url, parameters, ip, responsible_type, responsible_id, error_message, backtrace)
      end
    rescue
      render status: 500
    end
  end
end

