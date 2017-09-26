class SlackNotifyJob < ApplicationJob
  queue_as :default

  def perform(server_name, method, url, parameters, ip, responsible_type, responsible_id, error_message, backtrace)
    notifier     = Slack::Notifier.new(ENV['SLACK_WEBHOOK_URL'], channel: ENV['SLACK_CHANNEL'], username: 'Error notifier')
    notification = notification(server_name, method, url, parameters, ip, responsible_type, responsible_id, error_message, backtrace)

    notifier.ping notification
  end

  private

  def notification(server_name, method, url, parameters, ip, responsible_type, responsible_id, error_message, backtrace)
    responsible = (responsible_type == "Agent") ? Agent.find_by_id(responsible_id) : User.find_by_id(responsible_id)

    %(
*Server: #{server_name}*
*Date:* #{Time.current}

`#{error_message}`  :scream:

*Request*
```
URL: #{method} #{url}
Parameters: #{parameters}
IP: #{ip}
#{responsible_message(responsible)}
```

*Backtrace* :poop: ```#{backtrace}```
    )
  end

  def responsible_message(responsible)
    return "User: not connected" if responsible.blank?

    if responsible.is_a? Agent
      message =  "Agent: #{responsible.fullname} (##{responsible.id}), #{responsible.intervenant.try(:raison_sociale)}\n"
      message << "Email: #{responsible.username}"
    end

    if responsible.is_a? User
      message =  "User: #{responsible.fullname} (##{responsible.id})\n"
      message << "Email: #{responsible.email}"
    end

    message
  end
end
