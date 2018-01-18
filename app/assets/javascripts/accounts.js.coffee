(($) ->

  # By default select country from account[country]
  $(document).on "cocoon:after-insert", (e, addedShop)->
    country = $('#account_country option:selected').val()
    addedShop.find('select[id^="account_shops_attributes_"]').val(country)

) jQuery
