(($) ->

  $(document).on 'click', '.flip_users', (e)->
    e.preventDefault()
    arrow = $(this).find("small")
    section = $(this).parent().children(".users_filter")

    section.slideToggle(
      250
      =>
        arrow.html(if section.css('display') is 'none' then "&#9668;" else "&#9660;")
    )

  $(document).on 'change', '#opportunities_sort', ->
    $('#loading').show()
    $.get "/dashboard/redraw", {
      stages: crm.grab_stages(),
      groups: crm.grab_groups(),
      users: crm.grab_users(),
      sort: crm.grab_sort(),
      view: crm.grab_view(),
      query: crm.grab_query()
    }, ->
      $('#loading').hide()

  $(document).on 'click', '.overview_basic-button', (e)->
    e.preventDefault()
    $(this).toggleClass('active')
    $('.overview_detailed-button').toggleClass('active')
    $('.log').toggle()
    $('.dashboard_tools').toggle()
    $('li.highlight.opportunity').css({'border-bottom-width': '1px'})

  $(document).on 'click', '.overview_detailed-button', (e)->
    e.preventDefault()
    $(this).toggleClass('active')
    $('.overview_basic-button').toggleClass('active')
    $('.log').toggle()
    $('.dashboard_tools').toggle()
    $('li.highlight.opportunity').css({'border-bottom-width': '0px'})

  $(document).on 'click', '.hide-comments li.comment', (e)->
    e.preventDefault()
    e.stopPropagation()
    comments = $(this).parent().find('li.comment').slice(1)
    return unless comments.length
    comments.each ->
      $(this).slideToggle(250)

  $(document).on 'click', '.hide-comments li.comment a, textarea, form', (e)->
    e.stopPropagation()

  $(document).on 'click', '.add_comment', (e)->
    e.preventDefault()
    create_comment = $(this).parent().next().next().find('.dashboard_comment')
    comments = $(this).parent().next().next().find('li.comment:visible').slice(1)
    create_comment.slideToggle(250)
    return unless comments.length
    comments.each ->
      $(this).slideToggle(250)

  $(document).on 'opportunities-loaded', ->
    if $('.overview_basic-button').hasClass('active')
      $('.log').hide()
      $('.dashboard_tools').hide()

) jQuery
