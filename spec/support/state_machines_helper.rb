require "rspec"

RSpec::Matchers.define :should_have do |payment|
  match do |state|
    payment.send(@action)
    payment.send(state).to_sym == @expected_state
  end

  chain :equal_to do |expected_state|
    @expected_state = expected_state
  end

  chain :after_event do |action|
    @action = action
  end
end
