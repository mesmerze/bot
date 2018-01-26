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

  def user_select(asset, users, myself)
    user_options = user_options_for_select(users, myself)
    select(asset, :assigned_to, user_options,
           { include_blank: t(:unassigned) },
           style: 'width: 160px;',
           class: 'select2')
  end

  def user_options_for_select(users, myself)
    (users - [myself]).map { |u| [u.full_name, u.id] }.prepend([t(:myself), myself.id])
  end

  def opportunity_group_checkbox(value)
    checked = true
    url = url_for(action: :filter)
    onclick = %{
      $(this).siblings().find("input:checkbox").prop('checked', $(this).prop('checked'));
      var values = [];
      var users = [];
      $('input[name=&quot;group[]&quot;]').filter(':checked').each(function () {
        values.push(this.value);
      });
      $('input[name=&quot;user[]&quot;]').filter(':checked').each(function () {
        users.push(this.value);
      });
      $('#loading').show();
      $('#overlay').show();
      $.post('#{url}', {groups: values.join(','), users: users.join(',')}, function () {
        $('#loading').hide();
        $('#overlay').hide();
      });
    }.html_safe
    check_box_tag("group[]", value, checked, id: "checkbox_group_#{value}", onclick: onclick)
  end

  def opportunity_group_users_checkbox(value)
    checked = true
    url = url_for(action: :filter)
    onclick = %{
      var groups = [];
      var users = [];
      $('input[name=&quot;group[]&quot;]').filter(':checked').each(function () {
        groups.push(this.value);
      });
      $('input[name=&quot;user[]&quot;]').filter(':checked').each(function () {
        users.push(this.value);
      });
      $('#loading').show();
      $('#overlay').show();
      $.post('#{url}', {groups: groups.join(','), users: users.join(',')}, function () {
        $('#loading').hide();
        $('#overlay').hide();
      });
    }.html_safe
    check_box_tag("user[]", value, checked, id: "checkbox_user_#{value}", onclick: onclick, style: "margin: 0 0 0 20px;")
  end
end
