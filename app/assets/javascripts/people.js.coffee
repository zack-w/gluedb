# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
	$('.date_picker').datepicker
    showOtherMonths: true,
    selectOtherMonths: true,
    changeYear: true,
    changeMonth: true,
    dateFormat: "mm/dd/yy",
    yearRange: '-80:+1'

  $('.input-group-btn button').click ->
    $('.date_picker').datepicker("show")

  $("select").selectpicker
      style: 'btn-info',
      menuStyle: 'dropdown-inverse'
      # size: 5
  
  update_delete_buttons()
  $('#setAuthorityLink').click ->
    $('#authorityIDModal').modal({})

  $('#save-authority-button').click ->
    $('#select_authority_id').submit()
