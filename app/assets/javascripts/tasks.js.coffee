(($) ->

  $(document).ready ->
    $('ul[id^="user_"]').each ->
      $(this).toggle($(this).find('.bucket:visible').children().length > 0)

) jQuery
