// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

jQuery.ajaxSetup({
  'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
});
function getFeedInfo(feedid) {
   $.ajax({
     url: "/feeds/tipinfo/"+feedid
   });
}
$(document).ready(function() {
  var currPage = 1;

  $("a[rel*=facebox]").facebox();
  $("a[rel^='prettyPhoto']").prettyPhoto({show_title: false, deeplinking: false});
  $("#new_post").submit(function() {
    $.post($(this).attr("action"), $(this).serialize(), null, "script");
    return false;
  });
  $("#new_usergroup").submit(function(){
    $.get($(this).attr("action"), $(this).serialize(), null, "script");
    return false;
  });
  // setup popup balloons (add contact / add task)
  $('.has-popupballoon').click(function(){
      // close all open popup balloons
      $('.popupballoon').fadeOut();
      $(this).next().fadeIn();
      return false;
  });

  $('.popupballoon .close').click(function(){
      $(this).parents('.popupballoon').fadeOut();
  });

  $(".feed-title").tooltip({ 
    onBeforeShow: function(event) {
      $('#feedtip').html("");
      getFeedInfo(this.getTrigger().attr("feed_id"));
    },
    position:'center right',
    offset:[-50, -150],
    tip: '#feedtip',
    delay:3000
  });
});

