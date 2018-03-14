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
    groups = []
    users = []
    view = 'detailed'
    $('input[name="group[]"]').filter(':checked').each ->
      groups.push(this.value)
    $('input[name="user[]"]').filter(':checked').each ->
      users.push(this.value)
    $('#loading').show()
    if $('.overview_basic-button').hasClass('active')
      view = 'basic'
    $.post "/users/filter", { groups: groups.join(','), users: users.join(','), sort: $(this).val(), view: view }, ->
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
    create_comment.slideToggle(250)

) jQuery
