// This is Alex Leung's script, extracted from default.html template.
// I think that something in this script is causing the template to break.

var initialHeight = 0;
var mode = "";
function reactToSize() {
    var aboutContainer = $("#about");
    if(aboutContainer.css("float") == 'right' && mode != "desktop") {
	if(initialHeight == 0) {
	    initialHeight = $(".content-holder.left").outerHeight();
	}
	mode = 'desktop';
	$(".content-holder").css("height", initialHeight);
    }
    else if(aboutContainer.css("float") == 'none' && mode != "tablet") {
	mode = "tablet";
	$(".content-holder.left").css("height", "auto");
    }
    else if(aboutContainer.css("border-radius") == '4px' && mode != mobile) {
	mode = 'mobile';
	$(".content-holder.right").css("height", "auto");
    }
    if(mode != "desktop") {
	$(".content-holder.right").css("height", $(".content-holder.left").outerHeight() + "px");
	$(".carousel").css("display", "none");
	//$(".carousel").css("height", $("video").outerHeight() + "px");
    } else {
	$(".carousel").attr("style", "");
    }
}
$(window).load(function() {
    $(".navbar").attr("style", "");
    reactToSize();
    $('<a class="twitter-timeline" height="'+$(".twitter-holder").innerHeight()+'" href="https://twitter.com/cohenadair" data-widget-id="614524478521868288">Tweets by @stevejb</a>').appendTo(".twitter-holder");
    !function(d,s,id){
	var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';
	if(!d.getElementById(id)){
	    js=d.createElement(s);
	    js.id=id;
	    js.src=p+"://platform.twitter.com/widgets.js";
	    fjs.parentNode.insertBefore(js,fjs);
	}
    }(document,"script","twitter-wjs");
});
$('.carousel').each(function(){
    $(this).carousel({
	interval: 1000 * 10
    });
});
$(window).resize(reactToSize);

