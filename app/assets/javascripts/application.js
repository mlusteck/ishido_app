// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require activestorage
//= require turbolinks
//= require jquery3
//= require_tree .

$(document).on( "turbolinks:load", function () {
  $(".place-stone").click( function () {
    var board_x = $(this).attr("data-board-x");
    var board_y = $(this).attr("data-board-y");
    $("#board_x").attr("value", board_x );
    $("#board_y").attr("value", board_y );
    $("#hidden-form").submit();
  });

  // color animation for four-way indicator
  function toFull(){
    $(".four-way").animate({opacity: '1.0'}, 1000, "swing", toDark );
  }
  function toDark(){
    $(".four-way").animate({opacity: '0.7'}, 800, "swing", toFull );
  }
  $(".four-way").animate({opacity: '1.0'}, 100, "swing", toDark );

}); // end document ready function
