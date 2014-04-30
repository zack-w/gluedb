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

		# .prev('.btn').on('click') e
    
  update_delete_buttons()
  #   $('.date_picker').datepicker({
  #     showOtherMonths: true,
  #     selectOtherMonths: true,
  #     dateFormat: "d MM, yy",
  #     yearRange: '-1:+1'
  #   }).prev('.btn').on('click', function (e) {
  #     e && e.preventDefault();
  #     $(datepickerSelector).focus();
  #   });
  #   $.extend($.datepicker, {_checkOffset:function(inst,offset,isFixed){return offset}});

  #   // Now let's align datepicker with the prepend button
