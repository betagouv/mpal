module Admin::BaseHelper
  BOOTSTRAP_ALERT_LEVEL = {
    error:     "danger",
    alert:     "danger",
    notice:    "success",
    warning:   "warning",
  }

  def alert_for(level)
    BOOTSTRAP_ALERT_LEVEL[level] || "info"
  end

  def custom_page_entries_info(collection)
    if collection.count <= 0
      I18n.t("will_paginate.page_entries_info.single_page.zero")
    elsif 1 == collection.count
      I18n.t("will_paginate.page_entries_info.single_page.one")
    else
      I18n.t("will_paginate.page_entries_info.single_page.other", { count: collection.count })
    end
  end

  def delete_link(url, name = nil)
    title = name.blank? ? "Supprimer cet élément ?" : "Supprimer « #{name} » ?"
    link_to icon("trash"), url, class: "btn btn-secondary btn-icon js-deleter", title: title
  end

  def export_filename(prefix)
    "export_#{prefix}_#{Time.now.strftime('%Y-%m-%d_%H-%M-%s')}.csv"
  end

  def format_date(date, format = :default)
    return '' if date.blank?
    date = date.to_date unless date.is_a?(Date)
    I18n.localize(date, format: format)
  end

  def has_flashes?
    flash.present? && (arr = [:error, :alert, :notice] & flash.keys.map(&:to_sym)).present? && (arr.detect { |x| flash[x].present? })
  end

  def icon(name, opts = {})
    classes = (opts.delete(:class) || "").to_s.split(" ")
    name = "glyphicon glyphicon-#{name}" unless name.starts_with?("glyphicon-")
    classes << name
    opts.merge!(:class => classes)
    capture do
      content_tag :i, "", opts
    end
  end

  def init_class_infos
    @__model_name_plural = controller_name
    @__model_name_singular = controller_name.singularize
    @__namespaces = params[:controller].split("/").map(&:downcase)
    @__namespaces.pop
    @__namespaces_ = @__namespaces.map { |x| "#{x}_" }.join
    true
  end

  def link_to_icon(name, url, opts = {})
    opts ||= {}
    opts[:class] = (opts[:class] || "").split(" ").reject(&:blank?)
    opts[:class] += ["btn", "btn-secondary", "btn-icon"]
    opts[:href] = url
    capture do
      content_tag :a, opts do
        concat icon name
      end
    end
  end

  def mail_to(email, name = "")
    str = name.present? ? "#{name} <#{email}>" : email
    link_to "mailto:#{URI::encode(str)}", title: email do
      concat "#{trunc(email)} "
      concat icon("new-window")
    end
  end

  def simple_form_classes(classes = [])
    array = (SimpleForm.default_form_class || '').split
    array += ['form-regular', 'form-with-alerts']
    array += classes.is_a?(String) ? classes.split(' ') : classes
    array.uniq
  end

  # Exemples:
  # opts = { form: f, kind: :update, icon: :none }
  # opts = { form: f, kind: :submit, icon: :calendar }
  def submit_button(opts = {})
    opts = { form: opts } if opts.is_a? SimpleForm::FormBuilder
    opts.symbolize_keys!
    model = opts[:form].object.class.name.underscore
    key = opts[:kind]
    key ||= (obj = opts[:form].object) && obj.new_record? ? "submit" : "update"
    opts[:icon] ||= ("create" == key ? "plus" : "ok")
    text = I18n.t("helpers.submit.#{model}.#{key}", default: [:"helpers.submit.defaults.#{key}", 'Valider'])
    capture do
      content_tag :div, class: "form-group" do
        content_tag :div, class: "form-field form-field-label" do
          content_tag(:button, type: :submit, class: "btn btn-primary btn-large btn-deco btn-submit", id: opts[:id]) do
            unless :none == opts[:icon]
              concat icon("#{opts[:icon]}")
            end
            concat text
          end
        end
      end
    end
  end

  def tab(tabs, name, force = false)
    tab = (tabs || {})[name.to_sym]
    return "" unless tab
    classes = ["tab-pane"]
    classes << "active" if force || @active_tab == name
    capture do
      content_tag :div, id: "tab-#{name}", class: classes, role: "tabpanel" do
        if block_given?
          yield
        end
      end
    end
  end

  def td_admin(admin, edit_url = nil)
    return td_no_admin "Système" unless admin
    kind = admin.class.to_s.underscore
    classes = edit_url ? "" : "link-ext-a"
    edit_url ||= send("edit_admin_#{kind}_path", id: admin.id)
    capture do
      content_tag :a, href: edit_url, title: admin.full_name, class: classes do
        content_tag :span, admin.full_name, class: "name"
      end
    end
  end

  def td_no_admin(text)
    capture do
      content_tag :span, text, class: "name"
    end
  end

  def trunc(text, length = 20)
    truncate(text.to_s, length: length, omission: '…')
  end
end
