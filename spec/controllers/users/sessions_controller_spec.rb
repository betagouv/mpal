require "rails_helper"

describe Users::SessionsController do
  describe "includes ApplicationConcern" do
    it { expect(Users::SessionsController.ancestors).to include ApplicationConcern }
  end
end
