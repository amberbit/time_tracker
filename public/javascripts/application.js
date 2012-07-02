// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$.fn.time_log_project_subselect_with_ajax = function(child) {
  var that = this;

  this.change(function() {
    $.ajax({
          type: 'POST',
          url: that.attr('rel'),
          data: "id="+that.val(),
          beforeSend: function(xhr) {
            xhr.setRequestHeader("Accept", "application/json");
          },
          success: function(data) {
            tasks_html = '<option value="">Any Task</option>';
            for(task in data)
              tasks_html += ('<option value="' + data[task]._id + '">' + data[task].name + '</option>\n');
            
            child.html(tasks_html);
          }
    });
  });
}
$("#time_log_project").time_log_project_subselect_with_ajax($("#time_log_task"));
$("#time_log_project").change();

task_log_entries = function(el) {
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
            entries_html = "<ul>\n"
            for(d in data) {
              var s = data[d].number_of_seconds;
              var date = new Date(Date.parse(data[d].created_at));
              entries_html += "<li>"+(s/3600).toFixed(0)+"h " + (s/60%60).toFixed(0)+"m " + s%60+"s - "
                           + date + "</li>\n";

            }

            entries_html += "</ul>\n";
            entries.html(entries_html);
          }
    });
  });
}
$('.task').each( function() { task_log_entries(this); });

$(".jump_to_url").live("change", function(event) {
  window.location = $(this).val();
});
