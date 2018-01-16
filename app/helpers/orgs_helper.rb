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
end
