(($) ->

  $(document).ready ->
    $('#teammates ul[id^="user_"]').each ->
      $(this).toggle($(this).find('.bucket:visible').children().length > 0)

  $(document).on 'change', 'select.entity_type:visible', ->
    row = $(this).parents('.assign_row')
    entity_type = $("option:selected", this).val()
    $.ajax 'tasks/assign',
      type: 'GET',
      data: { entity_type: entity_type },
      success: (data, textStatus, jqXHR) ->
        row.html(data)
        row.find('.entity').addClass('select2')
        row.find('.entity_type').addClass('select2')
        crm.make_select2()

  $(document).on 'click', '#assign_partial .links .ui-icon-plus', (e)->
    e.preventDefault()

    # clone form row which be appended
    new_row = $("#assign_row_form").clone()

    # toggle disabled for new row
    new_row.find('.entity').prop('disabled',false).addClass('select2')
    new_row.find('.entity_type').prop('disabled',false).addClass('select2')

    $(".assign_rows").append(new_row.html()).ready ->
      crm.make_select2()

  $(document).on 'click', '#assign_partial .assign_row .ui-icon-minus', (e)->
    e.preventDefault()
    $(this).parents("table.assign_row").remove()

) jQuery
