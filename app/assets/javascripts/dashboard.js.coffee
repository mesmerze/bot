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
    $('input[name="group[]"]').filter(':checked').each ->
      groups.push(this.value)
    $('input[name="user[]"]').filter(':checked').each ->
      users.push(this.value)
    $('#loading').show()
    $.post "/users/filter", { groups: groups.join(','), users: users.join(','), sort: $(this).val() }, ->
      $('#loading').hide()

) jQuery
