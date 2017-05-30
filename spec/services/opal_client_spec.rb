require 'rails_helper'

describe OpalClient do
  subject { OpalClient }

  it { expect(subject.headers["Content-Type"]).to eq "application/json" }
  it { expect(subject.headers["TOKEN"]).to eq ENV["OPAL_TOKEN"] }
end

