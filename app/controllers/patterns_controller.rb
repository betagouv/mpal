class PatternsController < ApplicationController
  layout "patterns"

  def index
    redirect_to patterns_forms_path
  end

  def forms
  end
end

