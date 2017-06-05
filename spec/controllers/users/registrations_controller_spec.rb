require "rails_helper"

describe Users::RegistrationsController do
  describe "includes ApplicationConcern" do
    it { expect(Users::RegistrationsController.ancestors).to include ApplicationConcern }
  end
end
