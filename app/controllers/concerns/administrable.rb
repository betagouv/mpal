require "active_support/inflector"

module Administrable
  extend ActiveSupport::Concern
  include Exportable

  # TODO:
  #   - use .safe_constantize and manage constant by module
  #   - check inflections with irregular words (like person => people, even if it's a bad idea to use it as table names)

  def self.included(base)
    base.class_eval do
      before_filter :check_model, only: [:edit, :update, :show, :destroy]
      authorize_resource controller_name.tableize.singularize.to_sym
    end
  end

  def tabs
    model = model_name.constantize
    h = { general: { text: "Général", icon: "th-list" } }
    @active_tab = (tab = params[:tab]).present? && h.has_key?(tab.to_sym) ? tab.to_sym : h.first.first
    h
  end

  def item_name(name = nil)
    if name.nil? && @item && @item.respond_to?(:name) && @item.name.present?
      name = @item.name
    end
    name
  end

  # Empty string as parameter doesn't show name
  def formatted_item_name(name = nil)
    name = item_name(name)
    name.present? ? "« #{@item.name} » " : ""
  end

  def model_name
    controller_name.classify
  end

  # Translate the model name based on I18n. Default to singular.
  # If translation is missing, use the english model name.
  def translate_model_name(count_or_kind = 1)
    key = :one
    if count_or_kind.is_a?(Integer)
      key = (1 < count_or_kind) ? :other : :one
    elsif count_or_kind.present?
      key = :other if :one != count_or_kind.to_sym
    end
    #t("activerecord.models.#{model_name.tableize.singularize}.#{key}", default: t("activerecord.models.defaults.#{key}"))
    fallback = model_name.tableize
    fallback = fallback.singularize if :one == key
    t("activerecord.models.#{model_name.tableize.singularize}.#{key}", default: fallback.humanize)
  end

  def namespaces
    splitted = params[:controller].split("/").map(&:downcase)
    splitted.pop # The controller's name
    #splitted.shift # Should be "Admin"
    splitted
  end

  def namespaces_
    namespaces.map { |x| "#{x.downcase}_" }.join
  end

  def index
    if request.xhr?
      @items = search(params)
      init_view
      return render layout: false
    end
    respond_to do |format|
      format.html {
        @items = search(params)
        #if 1 == @items.size
        #  flash[:notice] = "Nous n’avons trouvé qu’un seul résultat, le voici…"
        #  url = "edit_#{namespaces_}#{model_name.tableize.singularize}_path"
        #  url = "#{namespaces_}#{model_name.tableize.singularize}_path" unless self.respond_to?(url)
        #  return redirect_to send(url, { id: @items.first.id })
        #end
        init_view
      }
      format.csv  {
        if model_name.constantize.respond_to?(:to_csv)
          filename = export_filename(model_name.tableize)
          response.headers["Content-Type"]        = "text/csv; charset=#{csv_ouput_encoding.name}"
          response.headers["Content-Disposition"] = "attachment; filename=#{filename}"
          render text: model_name.constantize.to_csv
        end
      }
    end
  end

  def new
    p = params[model_name.tableize.singularize.to_sym] || {}
    @item = model_name.constantize.new(p)
    init_view
  end

  def create
    @item = model_name.constantize.new(strong_params_hash)
    if @item.save
      flash[:notice] = "#{translate_model_name.mb_chars.capitalize} #{formatted_item_name}créé(e)"
      return redirect_to(send("edit_#{namespaces_}#{model_name.tableize.singularize}_path", { id: @item.id }))
    end
    init_view
    render :new
  end

  def edit
    init_view
    authorize! :edit, @item
  end

  def update
    @item.attributes = strong_params_hash
    if @item.save
      flash[:notice] = "#{translate_model_name.mb_chars.capitalize} #{formatted_item_name}modifié(e)"
      return redirect_to(send("edit_#{namespaces_}#{model_name.tableize.singularize}_path", { id: @item.id }))
    end
    init_view
    render :edit
  end

  def show
    init_view
  end

  def destroy
    name = @item.name
    success = @item.destroy rescue false
    if request.xhr?
      return head(success ? :ok : :bad_request)
    end
    respond_to do |format|
      format.html {
        if success
          flash[:notice] = "#{translate_model_name.mb_chars.capitalize} #{formatted_item_name}supprimé(e)"
        else
          flash[:alert] = "#{translate_model_name.mb_chars.capitalize} #{formatted_item_name}ne peut pas être supprimé(e)"
        end
        return redirect_to(action: :index)
      }
      format.js   {
        raise
        head(success ? :ok : :bad_request)
      }
    end
  end

  def reorder
    if request.get?
      @items = model_name.constantize.ordered
      init_view
      return
    end
    raise "Illegal access: requires Ajax!" unless request.xhr?
    return head(:bad_request) if params[:list].blank?
    model_name.constantize.reorder params[:list]
    head :ok
  end

protected
  def check_model
    @item ||= model_name.constantize.where(id: params[:id]).first
    unless @item
      flash[:alert] = "Cet élément n’existe pas"
      redirect_to action: :index
    end
    @item
  end

  def search(search = {})
    p = params[:search] || {}
    m = model_name.constantize
    scoped = m.ordered.paginate(page: params[:page], per_page: @per_page)
    if m.respond_to?(:admin_for_text)
      scoped = scoped.admin_for_text(p[:text])
    end
    # TODO: add specific scopes
    # TODO: add includes (ex: .includes(:foo))
    scoped
  end

  def strong_params_hash
    (params || {}).require(model_name.tableize.singularize.to_sym).permit(strong_params)
  end

  def strong_params
    %w(active name)
  end

  def init_view
    @page_title = "#{translate_model_name(:other).mb_chars.capitalize} • #{app_name}"
    @display_sidebar = true
    @breadcrumbs ||= []
    @breadcrumbs << { key: model_name.tableize.to_sym, name: translate_model_name(:other).mb_chars.capitalize, url: send("#{namespaces_}#{model_name.tableize}_path") }
    @body_id = model_name.tableize
    case params[:action].to_sym
      when :new, :create
        page_heading = "Nouveau"
        @page_title = "#{page_heading} • #{@page_title}"
        @breadcrumbs << { key: "#{model_name.tableize}_new".to_sym, name: page_heading, url: send("new_#{namespaces_}#{model_name.tableize.singularize}_path") }
      when :edit, :update
        @tabs = tabs.dup
        @active_tab = params[:tab].present? && @tabs.has_key?(params[:tab].to_sym) ? params[:tab].to_sym : @tabs.first.first
        page_heading = item_name
        if page_heading.present?
          @page_title = "#{page_heading} • #{@page_title}"
          @breadcrumbs << { key: "#{model_name.tableize}_edit".to_sym, name: page_heading, url: send("edit_#{namespaces_}#{model_name.tableize.singularize}_path", { id: @item.id }) }
        end
      when :show
        @tabs = tabs.dup
        @active_tab = params[:tab].present? && @tabs.has_key?(params[:tab].to_sym) ? params[:tab].to_sym : @tabs.first.first
        page_heading = item_name
        if page_heading.present?
          @page_title = "#{page_heading} • #{@page_title}"
          @breadcrumbs << { key: "#{model_name.tableize}_show".to_sym, name: page_heading, url: send("#{namespaces_}#{model_name.tableize}_path", { id: @item.id }) }
        end
      when :reorder
        page_heading = "Réordonner"
        @page_title = "#{page_heading} • #{@page_title}"
        @breadcrumbs << { key: "#{model_name.tableize}_reorder".to_sym, name: page_heading, url: send("reorder_#{namespaces_}#{model_name.tableize}_path") }
    end
  end
end
