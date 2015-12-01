$(function(){
// Configure/customize these variables.
    var showChar = 375;  // How many characters are shown by default
    var ellipsestext = "...";
    var moretext = '<i class="fa fa-angle-double-down show-text" style="font-size:4rem;" title="View entire review"></i>';
    var lesstext = '<i class="fa fa-angle-double-up show-text" style="font-size:4rem;" title="Hide review"></i>';
    

    $('.more').each(function() {
        var content = $(this).html();
 
        if(content.length > showChar) {
 
            var c = content.substr(0, showChar);
            var h = content.substr(showChar, content.length - showChar);
 
            var html = c + '<span class="moreellipses">' + ellipsestext+ '&nbsp;</span><span class="morecontent"><span>' + h + '</span>&nbsp;&nbsp;<a href="" class="morelink">' + moretext + '</a></span>';
 
            $(this).html(html);
        }
 
    });
 
    $(".morelink").click(function(){
        if($(this).hasClass("less")) {
            $(this).removeClass("less");
            $(this).html(moretext);
        } else {
            $(this).addClass("less");
            $(this).html(lesstext);
        }
        $(this).parent().prev().toggle();
        $(this).prev().toggle();
        return false;
    });

    $("#yelp-link").click(function(){
        $("html, body").animate({
            scrollTop: $("#yelp").offset().top
        }, 1000)
    })

    $("#zomato-link").click(function(){
        $("html, body").animate({
            scrollTop: $("#zomato").offset().top
        }, 1000)
    })

    $("#bookenda-link").click(function(){
        $("html, body").animate({
            scrollTop: $("#bookenda").offset().top
        }, 1000)
    })

    $("#opentable-link").click(function(){
        $("html, body").animate({
            scrollTop: $("#opentable").offset().top
        }, 1000)
    })

    $("#search").submit(function(){
        $("#search").hide();
        $("#loading").show();
    })

});