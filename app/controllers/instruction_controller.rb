class InstructionController < ApplicationController
	before_action :authenticate_agent!
end
