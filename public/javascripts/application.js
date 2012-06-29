// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$.fn.subSelectWithAjax = function(child) {
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

$("#time_log_project").subSelectWithAjax($("#time_log_task"));
$("#time_log_project").change();

$(".jump_to_url").live("change", function(event) {
 window.location = $(this).val();
});
