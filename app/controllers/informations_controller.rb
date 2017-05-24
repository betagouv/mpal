class InformationsController < ApplicationController
  layout "informations"

  def faq
    @page_heading = t("menu.faq")
  end

  def terms_of_use
    @page_heading = t("menu.terms_of_use")
  end

  def legal
    @page_heading = t("menu.legal")
  end
end

