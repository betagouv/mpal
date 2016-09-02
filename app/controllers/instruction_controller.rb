class InstructionController < ApplicationController
  skip_before_action :authentifie
	before_action :authenticate_agent!
end
