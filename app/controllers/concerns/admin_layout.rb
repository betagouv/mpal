module AdminLayout
  def self.included(base)
    base.class_eval do
      helper Admin::BaseHelper
      layout :set_layout
      before_filter :clean_params
      before_filter :init_admin_layout
    end
  end

protected
  def clean_params
    [:page, :per_page].each { |attr| params.delete(attr) if params[attr].to_i <= 1 }
    true
  end

  def init_admin_layout
    @display_breadcrumbs = true
    @menu = Admin::BaseController::MENU.dup
    @breadcrumbs = [{ key: :home, name: "Accueil", url: admin_root_path }]
    @per_page_values = [10, 20, 30, 50, 100]
    if (search = params[:search]).present?
      [:page, :per_page].each do |p|
        search.delete p if search[p].to_i <= 0
      end
      @per_page = search[:per_page].to_i
    end
    @per_page = 30 unless @per_page_values.include?(@per_page)
    true
  end

  def init_view
    # Should be overriden by controllers
    true
  end

  def set_layout
    "admin_intern"
  end
end
