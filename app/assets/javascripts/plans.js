$(document).ready(function() {
  $('#Carriers').change(function(e) {
    $(".btn[value='Calculate']").attr('class','btn btn-primary');
    var id = $(e.target).val()
    $.getJSON('/carriers/'+id+'/show_plans', function(data) {
      $('#Plans').empty();
      $.each(data, function(key, value) {
        $('#Plans').append($('<option/>').attr("value", value._id).text(value.name));
      });
    });
  });

  $('#Plans').change(function() {
    $(".btn[value='Calculate']").attr('class','btn btn-primary');
  });

  $('.date_picker').change(function() {
    $(".btn[value='Calculate']").attr('class','btn btn-primary');
  });

  $('.btn[value="Calculate"]').click(function() {
    $(this).attr('class','btn btn-success');
  });
});

