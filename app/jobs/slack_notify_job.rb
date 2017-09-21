class SlackNotifyJob < ApplicationJob
  queue_as :default

  def perform(error_message, backtrace)
    error = "Error: 500 - Internal Server Error"
    message = ""
    message << "*Environment: #{ENV['ENV_NAME']}*\n"
    message << "*#{error}*\n"
    message << "*Date:* #{Time.now}\n"
    message << "*Error:* ```#{error_message}``` \n"
    message << "*Backtrace*: ```#{backtrace}``` \n"
    notifier = Slack::Notifier.new(ENV['SLACK_WEBHOOK_URL'], channel: ENV['SLACK_CHANNEL'], username: 'Error notifier')
    notifier.ping message
  end
end
