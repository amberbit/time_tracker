// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var monthNames = [ "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December" ];

$(".jump_to_url").live("change", function(event) {
  "use strict";
  window.location = $(this).val();
});

$(document).ready( function() {
  "use strict";
  $(".report-year").change();
  $('.show-task-entries').each( function() { task_log_entries(this); });

  $("#time_log_project").time_log_project_subselect_with_ajax($("#time_log_task"));
  $("#time_log_project").change();

  $("#show_accepted").live("change", function() {
    show_accepted_changed();
  });

  if( $.cookie('show_accepted') === 'true' )
    $('#show_accepted').prop('checked', true);
  else
    $('#show_accepted').prop('checked', false);

  show_accepted_changed();
});

function daysInMonth(y, m) {
  "use strict";
  return new Date(y,m,0).getDate();
}

function pad2(number) {
  "use strict";
  return (number < 10 ? '0' : '') + number;
}

$.fn.time_log_project_subselect_with_ajax = function(child) {
  "use strict";
  var that = this;
  that.toggleClass('expanded');

  this.change(function() {
    $.ajax({
          type: 'POST',
          url: that.attr('rel'),
          data: "id="+that.val(),
          beforeSend: function(xhr) {
            xhr.setRequestHeader("Accept", "application/json");
          },
          success: function(data) {
            var tasks_html = '<option value="">Any Task</option>';
            for(var task in data)
              tasks_html += ('<option value="' + data[task]._id + '">' + data[task].name + '</option>\n');

            child.html(tasks_html);
          }
    });
  });
};

function task_log_entries(el) {
  "use strict";
  var that = $(el);
  var params = el.getAttribute('rel').split(':');

  that.click('click', function() {
    var entries = $('#task-log-entries-'+params[1]);
    entries.toggle();
    if( !entries.is(':visible') )
      return;
    $.ajax({
          type: 'POST',
          url: params[0],
          data: "task_id="+params[1] + "&user_id="+params[2],
          beforeSend: function(xhr) {
            xhr.setRequestHeader("Accept", "application/json");
          },
          success: function(data) {
            var entries_html = "<ul>\n";
            for(var d in data) {
              var s = data[d].number_of_seconds;
              var date = new Date(Date.parse(data[d].created_at));
              entries_html += "<li><span class='time'>"+(s/3600).toFixed(0)+"h " +
                     (s/60%60).toFixed(0)+"m " + s%60+"s</span> " +
                     pad2(date.getDay()+1) + ' ' + monthNames[date.getMonth()] + ' ' +
                     pad2(date.getHours()) + ':' +pad2(date.getMinutes() ) +
                     ' <a href="/projects/'+ data[d].project_id +'/time_log_entries/'+ data[d]._id +
                     '/edit" class="btn btn-mini">Edit</a></li>' + "\n";
            }

            entries_html += "</ul>\n";
            entries.html(entries_html);
          }
    });
  });
}

$(".report-year, .report-month").live( "change", function() {
  "use strict";
  var year  = $(".report-year").val(),
      month = $(".report-month").val(),
      from = $("input[name=from]"),
      to = $("input[name=to]"),
      current_date = new Date(),
      current_year = current_date.getFullYear(),
      current_month = current_date.getMonth()+1,
      current_day = current_date.getDate(),
      from_str = '',
      to_str = '';

  if(parseInt(year, 10) === current_year) {
    for(var i=1; i<=12; i++)
      if (i <= current_month)
        $(".report-month").children()[i].style.display = 'block';
      else
        $(".report-month").children()[i].style.display = 'none';

    if(parseInt(month, 10) > current_month) {
      $(".report-month").val(pad2(current_month));
      month = pad2(current_month);
    }
  }
  else
    for(var j=1; j<=12; j++)
      $(".report-month").children()[j].style.display = 'block';

  if(year === '') {
    from_str += $(".report-year").children()[1].text;
    to_str += current_year.toString();
  }
  else {
    from_str += year;
    to_str += year;
  }

  if(month === '') {
    from_str += '-01';
    if(year === '' || parseInt(year, 10) === current_year)
      to_str += '-' + pad2(current_month);
    else
      to_str += '-12';
  }
  else {
    from_str += '-' + month;
    to_str += '-' + month;
  }

  from_str += '-01';
  if(parseInt(year, 10) === current_year && parseInt(month, 10) === current_month ||
     parseInt(year, 10) === current_year && month === '' || year === '' && month === '')
    to_str += '-'+pad2(current_day);
  else
    to_str += '-'+daysInMonth(year, month);

  to.val(to_str);
  from.val(from_str);
});


function show_accepted_changed() {
  "use strict";
  var checked = $('#show_accepted').is(':checked');
  if(checked)
    $('.accepted').show();
  else
    $('.accepted').hide();

  $.cookie('show_accepted', checked, { path: '/' });
}

