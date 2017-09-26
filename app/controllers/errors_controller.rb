class ErrorsController < ActionController::Base
  layout 'informations'

  def not_found
    render status: 404
  end

  def internal_server_error
    begin
      exception = request.env['action_dispatch.exception']
      message = exception.message.to_s
      backtrace = exception.backtrace[0..9].join("\n")
      SlackNotifyJob.perform_later(message, backtrace)
    ensure
      render status: 500
    end
  end
end

