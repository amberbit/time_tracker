// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(".jump_to_url").live("change", function(event) {
  window.location = $(this).val();
});

if( $.cookie('show_accepted') === 'true' )
  $('#show_accepted').prop('checked', true);
else 
  $('#show_accepted').prop('checked', false);

function show_accepted_changed() {
  var checked = $('#show_accepted').is(':checked');
  if(checked)
    $('.accepted').show();
  else
    $('.accepted').hide();

  $.cookie('show_accepted', checked, { path: '/' });
}

$("#show_accepted").change(function() {
  show_accepted_changed();
});

show_accepted_changed();
