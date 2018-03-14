(($) ->

  $(document).on 'change', '#lead_account_attributes_id', ->
    selected_id = $('#lead_account_attributes_id option:selected')[0].value
    $.ajax "/accounts/#{selected_id}/lead",
      type: 'GET'
      dataType: 'html'
      success: (data, textStatus, jqXHR) ->
        $('#lead').html(data)

) jQuery
