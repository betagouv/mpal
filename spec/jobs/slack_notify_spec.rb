require "rails_helper"

describe SlackNotifyJob do
  let(:time)           { Time.new(2017) }
  let(:environment)    { ENV['ENV_NAME'] }
  let(:message)        { "message" }
  let(:backtrace)      { "backtrace" }
  let(:notification)   { "*Environment: #{environment}*\n*Error: 500 - Internal Server Error*\n*Date:* #{time}\n*Error:* ```#{message}``` \n*Backtrace*: ```#{backtrace}``` \n"}

  before { allow(Time).to receive(:now).and_return(time) }

  it "enqueue the SlackNotifyJob" do
    expect{ SlackNotifyJob.perform_later(message, backtrace) }.to enqueue_job.exactly(:once)
  end

  it "send a message to the specific Slack channel" do
    expect(Slack::Notifier).to receive(:new).with(ENV['SLACK_WEBHOOK_URL'], channel: ENV['SLACK_CHANNEL'], username: 'Error notifier').and_call_original
    expect_any_instance_of(Slack::Notifier).to receive(:ping).with(notification)

    SlackNotifyJob.perform_now(message, backtrace)
  end
end

