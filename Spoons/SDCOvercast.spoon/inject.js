// css tweaks
// overcast.com doesn't allow css injection via traditional means
$('.navlink:eq(1), #speedcontrols').hide();
$('h2.ocseparatorbar:first()').css({
  marginTop: '0px'
});
if ($('#audioplayer').length > 0) {
  $('.titlestack').prev().removeClass('marginbottom1').css({
    marginBottom: '8px'
  });
  $('#progressbar').css({
    marginTop: '8px'
  });
  $('.fullart_container').css({
    float: 'left',
    width: '20%'
  });
  $('#speedcontrols').next().css({
    clear: 'both',
    fontSize: '12px',
    marginTop: '20px'
  });
  $('#playcontrols_container').css({
    margin: '13px 0px 13px 20%',
    width: '80%'
  });
}

// refresh home page
if (window.location.href == thome) {
  setTimeout(function() {
    location.reload();
  }, 60 * 1000);
}

// check play status
setInterval(function() {
  var isAudioPlaying = false;
  if ($('#audioplayer').length > 0 && !$('#audioplayer').prop('paused')) {
    isAudioPlaying = true;
  } webkit.messageHandlers.idhsovercastwebview.postMessage({ isPlaying: isAudioPlaying });
}, 3000);
