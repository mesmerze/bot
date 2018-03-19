# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
module UsersHelper
  def language_for(user)
    if user.preference[:locale]
      _locale, language = languages.detect { |locale, _language| locale == user.preference[:locale] }
    end
    language || "English"
  end

  def sort_by_language
    languages.sort.map do |locale, language|
      %[{ name: "#{language}", on_select: function() { #{redraw(:locale, [locale, language], url_for(action: :redraw, id: current_user))} } }]
    end
  end

  def all_users
    User.by_name
  end

  def user_select(options = {})
    users = options.fetch(:users, all_users)
    myself = options.fetch(:myself, current_user)
    asset = options.fetch(:asset, :opportunity)
    blank_option = asset == :opportunity ? {} : { include_blank: t(:unassigned) }

    user_options = user_options_for_select(users, myself)
    select(asset, :assigned_to, user_options,
           blank_option,
           style: 'width: 160px;',
           class: 'select2')
  end

  def user_options_for_select(users, myself)
    (users - [myself]).map { |u| [u.full_name, u.id] }.prepend([t(:myself), myself.id])
  end

  def opportunity_group_checkbox(value)
    onclick = %{
      $(this).siblings().find("input:checkbox").prop('checked', $(this).prop('checked'));
      crm.grab_filters();
    }.html_safe
    check_box_tag("group[]", value, true, id: "checkbox_group_#{value}", onclick: onclick)
  end

  def opportunity_group_users_checkbox(value)
    onclick = %{
      crm.grab_filters();
    }.html_safe
    check_box_tag("user[]", value, true, id: "checkbox_user_#{value}", onclick: onclick, style: "margin: 0 0 0 20px;")
  end

  def dashboard_stage_checkbox(value)
    onclick = %{
      crm.grab_filters();
    }.html_safe
    check_box_tag("stage[]", value, true, id: value, onclick: onclick)
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
end
