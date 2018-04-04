(($) ->

  $(document).on 'click', '#meetings-index .tabs a', (e)->
    e.preventDefault()
    meetings = $(this).data('meetings-index')
    $(this).addClass('active') unless $(this).hasClass('active')
    $('#loading').show()
    if meetings == 'done'
      $('#upcoming').removeClass('active')
    else
      $('#done').removeClass('active')

    $.ajax "/meetings.js",
      type: 'GET'
      data: { meetings: meetings }
      success: (data, textStatus, jqXHR) ->
        $('#loading').hide()

  $(document).on 'click', '.flip_summary', (e)->
    e.preventDefault()
    $(this).toggleClass('ui-icon-carat-1-s')
    $(this).parent().find('.summary').slideToggle(150)

  $(document).on 'click', '.list-meetings, .calendar-meetings', (e)->
    e.preventDefault()

    users = $("input[name='user[]']").filter(':checked').map(-> return this.value).get()

    calendar = $('#calendar').fullCalendar({
      defaultView: 'month',
      header: { left: 'month,agendaWeek, title' },
      events: {
        url: '/meetings/calendar.json',
        data: { users: users }
      }
    })

    view = $(this).data('meetings-view')
    unless $(this).hasClass('active')
      $('.format-buttons li a').removeClass('active')
      $(this).addClass('active')
    if view == 'calendar'
      $('#meetings-index').hide()
      if $('#create_meeting').children().length > 0
        crm.flip_form('create_meeting')
        crm.set_title('create_meeting', 'Meetings')
      $('.create_asset').css('visibility', 'hidden')
    else
      $('#meetings-index').show()
      $('.create_asset').css('visibility', 'visible')
      calendar.fullCalendar('destroy')

  $(document).on 'click', "#meetings_filters input[name='user[]']", (e)->

    calendar = $('#calendar').fullCalendar('getCalendar')

    if calendar
      users = $("input[name='user[]']").filter(':checked').map(-> return this.value).get()
      calendar.removeEventSources()
      calendar.addEventSource({
        url: '/meetings/calendar.json',
        data: { users: users }
      })

) jQuery
