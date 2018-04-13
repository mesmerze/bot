# frozen_string_literal: true

module DashboardHelper
  def dashboard_stage_checkbox(value)
    enabled = value != :lost
    onclick = %{
      crm.grab_filters();
    }.html_safe
    check_box_tag("stage[]", value, enabled, id: value, onclick: onclick)
  end

  def dashboard_buttons(related, assets)
    asset = assets.to_s.singularize
    create_id  = "create_#{asset}"
    create_url = controller.send(:"new_#{asset}_path")

    content_tag :div, class: 'dashboard_tools' do
      html = link_to_inline(create_id, create_url, related: dom_id(related), text: t(create_id), plain: true, class: 'dashboard_button')
      html << link_to('#', class: 'add_comment') do
        content_tag(:span, t(:add_note))
      end
    end
  end

  def account_type(type)
    case type
    when 'customer_restaurant'
      content_tag(:span, " | ") + content_tag(:div, t(:restaurant), class: 'type-strip', style: 'background-color: #d6f5d6;')
    when 'customer_hotel'
      content_tag(:span, " | ") + content_tag(:div, t(:hotel), class: 'type-strip', style: 'background-color: #fff4b3;')
    when 'customer_other'
      content_tag(:span, " | ") + content_tag(:div, t(:other), class: 'type-strip', style: 'background-color: #f2f2f2;')
    end
  end

  def account_systems(account)
    html = ''
    return html unless account
    account.account_systems.each do |system|
      if system.system.system_type == 'tms'
        message = system.system.maker + ' ' + system.expiration_date.strftime('%^b %Y')
        html += content_tag(:span, " | ") + content_tag(:div, message, class: 'type-strip wide-strip', style: 'color:white; background-color: #FF6347;')
      end
    end && html.html_safe
  end
end
