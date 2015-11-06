(function($) {
  $(function() {

    $(".main_button").click(function () {
      $.post("../cgi-bin/index.cgi", {"name": "query"
                         },
        function(data){
          $("#main_div").append(data['text']);
        }, "json");
    });

  });
})(jQuery);

$(document).on('click', '#main_button', function() { 
  $.post("../cgi-bin/index.cgi", {"name": "query"
                     },
    function(data){
      $("#main_div").append(data['text']);
    }, "json");
});
