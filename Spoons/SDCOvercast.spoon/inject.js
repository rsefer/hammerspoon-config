/* css tweaks - overcast.com doesn't allow css injection via traditional means */
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

var progress = 0;

function sendProgress() {
  var isAudioPlaying = false;
  if ($('#audioplayer').length > 0) {
    if (!$('#audioplayer').prop('paused')) {
      isAudioPlaying = true;
    }
    var audioPlayer = document.getElementById('audioplayer');
    progress = audioPlayer.currentTime / audioPlayer.duration;
  }
  if (!progress) {
    progress = 0;
  }
  webkit.messageHandlers.idhsovercastwebview.postMessage({
    isPlaying: isAudioPlaying,
    progress: progress,
    podcast: {
      name: $('.titlestack .ocbutton').html(),
      episodeTitle: $('.titlestack .title').html(),
    }
  });
}

if (window.location.href == thome) {
  webkit.messageHandlers.idhsovercastwebview.postMessage({
    page: 'home'
  });
  setTimeout(function() {
    location.reload();
  }, 60 * 1000);
} else {
  sendProgress();
  setTimeout(function() {
    sendProgress();
  }, 2 * 1000);
  setInterval(function() {
    sendProgress()
  }, 15 * 1000);
}
