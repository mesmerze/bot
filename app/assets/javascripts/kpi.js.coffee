(($) ->

  $(document).on 'change', '.kpi-user', ->
    selected_users = $(this).val()
    selected_countries = $('.kpi-country').val()
    unless selected_users
      selected_groups = $('.kpi-group').val()
    $.ajax "/analysis/draw_kpi",
      type: 'GET',
      data: { users: selected_users, countries: selected_countries, groups: selected_groups }

  $(document).on 'change', '.kpi-country', ->
    selected_countries = $(this).val()
    selected_users = $('.kpi-user').val()
    unless selected_users
      selected_groups = $('.kpi-group').val()
    $.ajax "/analysis/draw_kpi",
      type: 'GET',
      data: { users: selected_users, countries: selected_countries, groups: selected_groups }

  $(document).on 'change', '.kpi-group', ->
    selected_groups = $(this).val()
    $.ajax "/analysis/draw_kpi",
      type: 'GET',
      data: { groups: selected_groups, redraw: true }

  $(document).ready ->
    $('.select2-multi').select2MultiCheckboxes()
    if $('#analysis_kpis').length
      $.ajax "/analysis/draw_kpi",
        type: 'GET'

) jQuery
