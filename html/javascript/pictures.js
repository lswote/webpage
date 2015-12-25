$(document).ready(function() {
  var query_string = location.search;
  var path = "/Volumes/HammondFamily/Pictures/Archive";
  var query = query_string.split("=");
  if (query.length >= 2) {
    path = query[1];
  }
  $.post("/cgi-bin/pictures.cgi", {name: "pictures", path: path, 'base': "/Volumes/HammondFamily/Pictures/Archive"},
    function (result) {
      console.log("ready", result);
      $("#main_body").append(result["text"]);
    }, "json");
});

function post_url(path, base){
  $("#main_div").hide();
  $("#busy_div").show();
  $.post("/cgi-bin/pictures.cgi", {path: path, base: base},
    function (result) {
      console.log("post_url", result);
      if (result["count"] > 1) {
        $("#main_body").html(result["text"]);
      }
      else {
        $("#main_div").html(result["text"]);
      }
      $("#busy_div").hide();
      $("#main_div").show();
    }, "json");
};
