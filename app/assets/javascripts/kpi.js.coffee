(($) ->

  $(document).on 'change', '.kpi-user', ->
    selected_user= $("option:selected", this).val()
    selected_countries = $('.kpi-country').val()
    $.ajax "/analysis/draw_kpi",
      type: 'GET',
      data: { user_id: selected_user, countries: selected_countries }

  $(document).on 'change', '.kpi-country', ->
    selected_countries = $(this).val()
    selected_user = $('.kpi-user').val()
    if selected_user
      $.ajax "/analysis/draw_kpi",
        type: 'GET',
        data: { user_id: selected_user, countries: selected_countries }

  $(document).ready ->
    $('.select2-multi').select2MultiCheckboxes()

) jQuery
