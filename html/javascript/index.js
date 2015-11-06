$(document).ready(function() {
  $.post("../cgi-bin/index.cgi", {"name": "index"},
    function(data){
      $("#index_div").append(data['text']);
    }, "json");
});
