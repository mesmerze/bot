# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
module LeadsHelper
  RATING_STARS = 5

  #----------------------------------------------------------------------------
  def stars_for(lead)
    star = '&#9733;'
    rating = lead.rating.to_i
    (star * rating).html_safe + content_tag(:font, (star * (RATING_STARS - rating)).html_safe, color: 'gainsboro')
  end

  #----------------------------------------------------------------------------
  def link_to_convert(lead)
    link_to(t(:convert), convert_lead_path(lead),
            method: :get,
            with:   "{ previous: crm.find_form('edit_lead') }",
            remote: true)
  end

  #----------------------------------------------------------------------------
  def link_to_reject(lead)
    link_to(t(:reject) + "!", reject_lead_path(lead), method: :put, remote: true)
  end

  #----------------------------------------------------------------------------
  def confirm_reject(lead)
    question = %(<span class="warn">#{t(:reject_lead_confirm)}</span>)
    yes = link_to(t(:yes_button), reject_lead_path(lead), method: :put)
    no = link_to_function(t(:no_button), "$('#menu').html($('#confirm').html());")
    text = "$('#confirm').html( $('#menu').html() );\n"
    text += "$('#menu').html('#{question} #{yes} : #{no}');"
    text.html_safe
  end

  # Sidebar checkbox control for filtering leads by status.
  #----------------------------------------------------------------------------
  def lead_status_checkbox(status, count)
    entity_filter_checkbox(:status, status, count)
  end

  # Returns default permissions intro for leads
  #----------------------------------------------------------------------------
  def get_lead_default_permissions_intro(access)
    case access
    when "Private" then t(:lead_permissions_intro_private, t(:opportunity_small))
    when "Public" then t(:lead_permissions_intro_public, t(:opportunity_small))
    when "Shared" then t(:lead_permissions_intro_shared, t(:opportunity_small))
    end
  end

  # Do not offer :converted status choice if we are creating a new lead or
  # editing existing lead that hasn't been converted before.
  #----------------------------------------------------------------------------
  def lead_status_codes_for(lead)
    if lead.status != "converted" && (lead.new_record? || lead.contact.nil?)
      Setting.unroll(:lead_status).delete_if { |status| status.last == :converted }
    else
      Setting.unroll(:lead_status)
    end
  end

  # Lead summary for RSS/ATOM feed.
  #----------------------------------------------------------------------------
  def lead_summary(lead)
    summary = []
    summary << (lead.status ? t(lead.status) : t(:other))

    if lead.company? && lead.title?
      summary << t(:works_at, job_title: lead.title, company: lead.company)
    else
      summary << lead.company if lead.company?
      summary << lead.title if lead.title?
    end
    summary << "#{t(:referred_by_small)} #{lead.referred_by}" if lead.referred_by?
    summary << lead.email if lead.email.present?
    summary << "#{t(:phone_small)}: #{lead.phone}" if lead.phone.present?
    summary << "#{t(:mobile_small)}: #{lead.mobile}" if lead.mobile.present?
    summary.join(', ')
  end

  def lead_account_select(options = {})
    options[:selected] = @account&.id || 0
    accounts = ([@account.new_record? ? nil : @account] + Account.my(current_user).order(:name).limit(25)).compact.uniq
    collection_select 'lead[account_attributes]', :id, accounts, :id, :name,
                      { selected: options[:selected], include_blank: true },
                      style: 'width:330px;', class: 'select2',
                      placeholder: t(:select_an_account),
                      "data-url": auto_complete_accounts_path(format: 'json')
  end

  # Select an existing account for current lead or create a new one.
  #----------------------------------------------------------------------------
  def lead_account_select_or_create(form, &_block)
    options = {}
    yield options if block_given?

    content_tag(:div, class: "label #{options[:label]}") do
      t(:account).html_safe +
        content_tag(:span, id: 'account_create_title') do
          " (#{t :create_new} #{t :or} <a href='#' onclick='crm.show_select_lead_account(); return false;'>#{t :select_existing}</a>):".html_safe
        end +
        content_tag(:span, id: 'account_select_title') do
          " (<a href='#' onclick='crm.show_create_lead_account(); return false;'>#{t :create_new}</a> #{t :or} #{t :select_existing}):".html_safe
        end +
        content_tag(:span, ':', id: 'lead_account_disabled_title')
    end +
      lead_account_select(options) +
      form.text_field(:name, style: 'width:324px; display:none;')
  end
end
