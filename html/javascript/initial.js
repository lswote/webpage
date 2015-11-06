$(document).ready(function() {
  $.post("/cgi-bin/index.cgi", {name: "index"},
    function (result) {
      $("#main_body").append(result["text"]);
    }, "json");
});
