// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(".jump_to_url").live("change", function(event) {
 window.location = $(this).val();
});
