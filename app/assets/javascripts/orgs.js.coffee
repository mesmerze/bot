# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
(($) ->

  window.crm ||= {}

  $(document).on "cocoon:after-insert", ->
    crm.make_select2()

) jQuery
