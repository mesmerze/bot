# frozen_string_literal: true

module SystemsHelper
  def systems_section(related, assets)
    asset = assets.to_s.singularize
    create_id  = "create_#{asset}"
    create_url = controller.send(:"new_#{asset}_path")

    html = tag(:br)
    html << content_tag(:div, link_to_inline(create_id, create_url, related: dom_id(related), text: t(:add_system)), class: "subtitle_tools")
    html << content_tag(:div, t(:systems), class: :subtitle, id: "create_#{asset}_title")
    html << content_tag(:div, "", class: :remote, id: create_id, style: "display:none;")
  end

  def satisfaction_level(satisfaction)
    case satisfaction
    when 'happy'
      content_tag(:span, " | ") + content_tag(:div, t(:happy), class: 'type-strip', style: 'color:white; background-color: #008000;')
    when 'moderate'
      content_tag(:span, " | ") + content_tag(:div, t(:moderate), class: 'type-strip', style: 'background-color: #FFFF00;')
    when 'unhappy'
      content_tag(:span, " | ") + content_tag(:div, t(:unhappy), class: 'type-strip', style: 'color:white; background-color: #FF0000;')
    end
  end
end
