setInterval(function() {
	$('a').removeAttr('target').click(function(e) {
		e.preventDefault();
		openLink($(this).attr('href'));
	});
}, 2000);

function openLink(link) {
	webkit.messageHandlers.idhsdashwebview.postMessage({
		isLink: true,
		linkTarget: link
	});
}
