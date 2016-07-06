class ToolsController < ApplicationController

  def reset_base
    Tool.reset_base
  end
end
