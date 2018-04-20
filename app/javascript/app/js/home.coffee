(($) ->

  $(document).on 'click', '.show_entities_message', (e)->
    $(this).siblings('.hidden_entities').slideDown(250)
    $(this).hide()

  $(document).on 'click', '.hide_entities_message', (e)->
    $(this).parent().siblings('.show_entities_message').show()
    $(this).parent().slideUp(250)

) jQuery
