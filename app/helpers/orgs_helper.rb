# frozen_string_literal: true

module OrgsHelper
  def revenue(org)
    amount = 0
    org.accounts.each do |acc|
      acc.opportunities.each { |opp| amount += opp.amount }
    end && number_to_currency(amount)
  end

  def account_section(related, assets)
    asset = assets.to_s.singularize
    create_id  = "create_#{asset}"
    create_url = controller.send(:"new_#{asset}_path")

    html = tag(:br)
    html << content_tag(:div, link_to_inline(create_id, create_url, related: dom_id(related), text: t(create_id)), class: "subtitle_tools")
    html << content_tag(:div, t(assets), class: :subtitle, id: "create_#{asset}_title")
    html << content_tag(:div, "", class: :remote, id: create_id, style: "display:none;")
  end

  # Generates a select list with the first 25 orgs
  # and prepends the currently selected org, if any.
  #----------------------------------------------------------------------------
  def org_select(options = {})
    options[:selected] = @org&.id.to_i
    width = options.fetch(:width, 224)
    orgs = ([@org&.new_record? ? nil : @org] + Org.order(:name).limit(25)).compact.uniq
    collection_select :org, :id, orgs, :id, :name,
                      { include_blank: true },
                      style: "width:#{width}px;", class: 'select2',
                      placeholder: t(:select_org),
                      "data-url": auto_complete_orgs_path(format: 'json')
  end

  # Select an existing org or create a new one.
  #----------------------------------------------------------------------------
  def org_select_or_create(form, &_block)
    options = {}
    yield options if block_given?

    content_tag(:div, class: "label #{options[:label]}") do
      t(:org).html_safe +
        content_tag(:span, id: 'org_create_title') do
          " (#{t :create_new} #{t :or} <a href='#' onclick='crm.show_select_org(); return false;'>#{t :select_existing}</a>):".html_safe
        end +
        content_tag(:span, id: 'org_select_title') do
          " (<a href='#' onclick='crm.show_create_org(); return false;'>#{t :create_new}</a> #{t :or} #{t :select_existing}):".html_safe
        end +
        content_tag(:span, ':', id: 'org_disabled_title')
    end +
      org_select(options) +
      form.text_field(:name, style: 'width:220px; display:none;')
  end
end
