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

) jQuery
