(($) ->

  # handle account change in edit form
  $(document).on 'change', "#account_id", ->
    selected_account = $("option:selected", this).val()
    current_opportunity = $("#opportunity_id").val()
    path = $(location).attr("pathname").replace(/\/\d+\z/, '') # HACK Find another solution
    $.ajax "#{path}/shops",
      type: 'GET'
      data: { account_id: selected_account, opportunity_id: current_opportunity  }

  # handle remove relation
  $(document).on 'click', '#shops_partial .shop_row .ui-icon-minus', (e)->
    e.preventDefault()
    $(this).parents("table.shop_row").remove()

  # handle add relation
  $(document).on 'click', '.links .ui-icon-plus', (e)->
    e.preventDefault()

    # collect shops which already selected
    selected = $('.shop_rows .shop_id').map(->
      $(this).val()
    ).toArray()

    # clone form row which be appended
    new_row = $("#shop_row_form").clone()

    # toggle disabled for new row
    new_row.find('.shop_id').prop('disabled',false)
    new_row.find('.shop_num_seats').prop('disabled',false)

    # remove already selected shops from select options
    new_row.find('.shop_id option').each ->
      if selected.includes($(this).val())
        $(this).remove()
        return

    # not append new row if options empty
    options = new_row.find('.shop_id option')
    if options.length > 0
      $(".shop_rows").append(new_row.html())

      # fill num_seats after add row
      new_shop_id = new_row.find('.shop_id').val()
      $.ajax "/shops/#{new_shop_id}",
        type: 'GET'
        contentType: "application/json"
        dataType: 'json'
        success: (data, textStatus, jqXHR) ->
          $(".shop_rows").find(".shop_num_seats").last().val(data.shop.num_seats)
          $(".shop_rows").find(".shop_country").last().val(data.shop.country)
          $(".shop_rows").find(".shop_closed_date").last().val(data.shop.closed_date)
          $(".shop_rows").find(".shop_stage").last().val(data.shop.stage)

  # checkbox
  $(document).on 'change', "input[type='checkbox'].all_shops", ->
    # $('.shops_selection').toggle()
    if $(this).is(':checked')
      $('.shops_selection').slideUp('fast')
    else
      $('.shops_selection').slideDown('fast')

  # fill num_seats after select shop
  $(document).on 'change', '.shop_id', ->
    selected_shop = $("option:selected", this).val()
    num_to_be_filled = $(this).parent().parent().find(".shop_num_seats")
    country_to_be_selected = $(this).parent().parent().find(".shop_country")
    date_to_be_filled = $(this).parent().parent().find(".shop_closed_date")
    stage_to_be_selected = $(this).parent().parent().find(".shop_stage")
    $.ajax "/shops/#{selected_shop}",
      type: 'GET'
      contentType: "application/json"
      dataType: 'json'
      success: (data, textStatus, jqXHR) ->
        num_to_be_filled.val(data.shop.num_seats)
        country_to_be_selected.val(data.shop.country)
        date_to_be_filled.val(data.shop.closed_date)
        stage_to_be_selected.val(data.shop.stage)

) jQuery
