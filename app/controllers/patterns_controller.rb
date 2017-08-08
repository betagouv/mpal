class PatternsController < ApplicationController
  layout "patterns"

  def index
    redirect_to patterns_forms_path
  end

  def forms
    @page_heading = I18n.t("menu_patterns.forms.title")
  end

  def icons
    @page_heading = I18n.t("menu_patterns.icons.title")
  end
end

