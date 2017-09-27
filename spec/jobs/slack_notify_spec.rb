require "rails_helper"

describe SlackNotifyJob do
  let(:operateur) { create :operateur }
  let(:agent)     { create :agent, intervenant: operateur }

  let(:time)                { Time.local(2017) }
  let(:server_name)         { "www.mpal.dev" }
  let(:method)              { "GET" }
  let(:url)                 { "http://www.mpal.dev/500" }
  let(:parameters)          { "{\"controller\"=>\"errors\", \"action\"=>\"internal_server_error\"}" }
  let(:ip)                  { "127.0.0.1" }
  let(:error_message)       { "Exception de test" }
  let(:backtrace)           { "Backtrace" }
  let(:responsible_type)    { "Agent" }
  let(:responsible_id)      { agent.id }
  let(:responsible_message) { "Agent: #{agent.fullname} (##{agent.id}), #{agent.intervenant.raison_sociale}\nEmail: #{agent.username}" }
  let(:notification)        {
    %(
*Server: #{server_name}*
*Date:* #{time}

`#{error_message}`  :scream:

*Request*
```
URL: #{method} #{url}
Parameters: #{parameters}
IP: #{ip}
#{responsible_message}
```

*Backtrace* :poop: ```#{backtrace}```
    )
  }

  before { allow(Time).to receive(:current).and_return(time) }

  it "enqueue the SlackNotifyJob" do
    expect{ SlackNotifyJob.perform_later(server_name, method, url, parameters, ip, responsible_type, responsible_id, error_message, backtrace) }.to enqueue_job.exactly(:once)
  end

  it "send a message to the specific Slack channel" do
    expect(Slack::Notifier).to receive(:new).with(ENV['SLACK_WEBHOOK_URL'], channel: ENV['SLACK_CHANNEL'], username: 'Error notifier').and_call_original
    expect_any_instance_of(Slack::Notifier).to receive(:ping).with(notification)

    SlackNotifyJob.perform_now(server_name, method, url, parameters, ip, responsible_type, responsible_id, error_message, backtrace)
  end
end

