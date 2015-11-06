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

$(document).on('click', '.toggle', function() { 
  $self = $(self);
  $self.closest('table').next('.toggle').toggle();
  console.log($self);
  console.log($self.closest('table'));
  console.log($self.parent().closest('table'));
  console.log($self.parent().closest('table').next('.toggle'));
  console.log($('#toggletest'));
  //$('#toggletest').toggle();
});
