// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery.turbolinks
//= require jquery.raty
//= require ratyrate
//= require_tree .

var ready = function() {

/*********************************************************************
Landing Page: Fade Out
*********************************************************************/
  $("#click-search-button").click(function(){
    $("#fade-out-landing").fadeOut("slow");
  });


/*********************************************************************
Content Information Toggling
*********************************************************************/


/* SLIDER */
  var i = 0;
    var interval;
    var divs = $('.carousel > div');
    var circles = $('#circles > li');

    function cycle(){

        divs.removeClass('active').eq(i).addClass('active');

        circles.removeClass('active').eq(i).addClass('active');

        var img_width = divs.eq(i).children().width() + $('.carousel-control').width() * 2;
        $('#container').css('width', img_width + 'px');

        i = ++i % divs.length;

        clearTimeout(interval);
        interval = setTimeout(function() { cycle(); }, 4000);
    };

    $('.prev').click(function(){
        i = $('div.active').index() - 1;
        cycle();
    });

    $('.next').click(function(){
        var next = $('div.active').index() + 1;
        next === divs.length ? i = 0 : i = next;
        cycle();
    });

    $('#circles > li').click(function(){
        i = $(this).index();
        cycle();
    });

    cycle();

/* SLIDER */

  /* Album Songs */
  $(function(){
    $('.accordion h2').click(function() {
    $(this).toggleClass('active').find('i').toggleClass('fa-plus fa-minus')
      .closest('h2').siblings('h2')
      .removeClass('active').find('i').removeClass('fa-minus').addClass('fa-plus');
      $(this).next('.accordion_content').slideToggle().siblings('.accordion_content').slideUp();
    });
  });

  $(function(){$('.accordion_content').hide();});

/*********************************************************************
Facebook JS
*********************************************************************/

  (function(d, s, id) {
    var js, fjs = d.getElementsByTagName(s)[0];
    if (d.getElementById(id)) return;
    js = d.createElement(s); js.id = id;
    js.src = "//connect.facebook.net/en_US/sdk.js#xfbml=1&version=v2.3";
    fjs.parentNode.insertBefore(js, fjs);
  }(document, 'script', 'facebook-jssdk'));

/*********************************************************************
Twitter JS
*********************************************************************/

  !function(d,s,id) {
    var js,fjs=d.getElementsByTagName(s)[0],
    p=/^http:/.test(d.location)?'http':'https';
      if(!d.getElementById(id)) {
        js=d.createElement(s);
        js.id=id;js.src=p+"://platform.twitter.com/widgets.js";
        fjs.parentNode.insertBefore(js,fjs);
      }
    }
  (document,"script","twitter-wjs");

/*********************************************************************
Side Nav JS
*********************************************************************/

  // $('#bio-btn').click(function(){
  //   $('#bio').toggle();
  //   $('#albums, #pics, #YT, #twitter, #FB-comments').hide();
  // });

  // $('#albums-btn').click(function(){
  //   $('#albums').toggle();
  //   $('#bio, #pics, #YT, #twitter, #FB-comments').hide();
  // });

  // $('#pics-btn').click(function(){
  //   $('#pics').toggle();
  //   $('#albums, #bio, #YT, #twitter, #FB-comments').hide();
  // });

  // $('#YT-btn').click(function(){
  //   $('#YT').toggle();
  //   $('#albums, #pics, #bio, #twitter, #FB-comments').hide();
  // });

  // $('#twitter-btn').click(function(){
  //   $('#twitter').toggle();
  //   $('#albums, #pics, #YT, #twitter, #FB-comments').hide();
  // });

  // $('#FB-comments-btn').click(function(){
  //   $('#FB-comments').toggle();
  // });

  $("a[data-toggle2]").on("click", function(e) {
    e.preventDefault();  // prevent navigating
    var selector = $(this).data("toggle2");  // get corresponding element
    $("#bio, #albums, #pics, #YT, #twitter, #FB-comments").hide();
    $(selector).show();
  });

/*********************************************************************
Slide in Search JS
*********************************************************************/
  $(window).load(function(){
    $( ".thumbnail" ).show(1500).fadeIn("fast");
  });

};
$(document).ready(ready);
$(document).on('page:load', ready);

//=require turbolinks

