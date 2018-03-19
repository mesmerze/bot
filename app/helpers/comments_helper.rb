# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
module CommentsHelper
  def notification_emails_configured?
    config = Setting.email_comment_replies || {}
    config[:server].present? && config[:user].present? && config[:password].present?
  end

  def on_dashboard?
    controller_name == 'dashboard'
  end

  def advice_comment(org)
    partial = render(partial: "comments/new", locals: { commentable: org })
    onclick = "$('.comment.highlight.new_comment').replaceWith('#{j partial}');\n"
    content_tag(:div, class: 'comment highlight new_comment') do
      html = link_to avatar_for(current_user, size: :small), user_path(current_user)
      html << content_tag(:div, t(:opportunities_first), class: 'label', style: 'display: inline-block;')
      html << button_tag(t(:note_anyway), onclick: onclick)
    end
  end
end
