// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(".jump_to_url").live("change", function(event) {
  window.location = $(this).val();
});

$(".report-year, .report-month").live( "change", function() {
  var year  = $(".report-year").val();
  var month = $(".report-month").val();
  var from = $("input[name=from]");
  var to = $("input[name=to]");
  var current_date = new Date();
  var current_year = current_date.getFullYear();
  var current_month = current_date.getMonth()+1;
  var current_day = current_date.getDay()+1;
  from_str = '';
  to_str = '';

  if(year == current_year) {
    for(i=1; i<=12; i++)
      if ( i <= current_month )
        $(".report-month").children()[i].style.display = 'block';
      else
        $(".report-month").children()[i].style.display = 'none';
    
    if(parseInt(month) > current_month) {
      $(".report-month").val(pad2(current_month));
      month = pad2(current_month);
    }
  }
  else
    for(i=1; i<=12; i++)
      $(".report-month").children()[i].style.display = 'block';

  if(year == '') {
    from_str += $(".report-year").children()[1].text;
    to_str += current_year.toString();
  }
  else {
    from_str += year;
    to_str += year;
  }

  if(month == '') {
    from_str += '-01';
    if(year == '' || year == current_year)
      to_str += '-'+pad2(current_month);
    else 
      to_str += '-12';
  }
  else {
    from_str += '-'+month;
    to_str += '-'+month;
  }

  from_str += '-01';
  if(year == current_year && parseInt(month) == current_month || 
    year == current_year && month == '' || year == '' && month == '')
    to_str += '-'+pad2(current_day);
  else
    to_str += '-'+daysInMonth(year, month);

  to.val(to_str);
  from.val(from_str);
});

$(document).ready( function() {
  $(".report-year").change();
});

function daysInMonth(y, m) {
  return new Date(y,m,0).getDate(); 
}

function pad2(number) {
  return (number < 10 ? '0' : '') + number  
}
