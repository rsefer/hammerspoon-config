-- Reload Hammerspoon
-- local reloadWatcher = hs.pathwatcher.new(os.getenv('HOME') .. '/.hammerspoon/', hs.reload):start()
hs.hotkey.bind(hs.settings.get('hotkeyCombo'), '/', function()
	if spoon.SDCTimer.timerMain:running() then
		spoon.SDCTimer:toggleTimer()
		hs.timer.usleep(2000000)
	end
	print('Hammerspoon is reloading')
	hs.reload()
end)

-- Restart Hammerspoon
-- (in Shortcuts OR Settings > Keyboard > Shortcuts)
-- {'cmd', 'alt', 'ctrl'}, -
-- The above is not included in the Hammerspoon config because they won't
-- work if Hammerspoon is not running (launch) or frozen (force quit)

-- Do Not Disturb toggle
-- (in Settings > Keyboard > Shortcuts)
-- {'cmd', 'alt', 'ctrl'}, f17

-- Full Brightness
hs.hotkey.bind(hs.settings.get('hotkeyCombo'), 'B', function()
	for i = 1, 16, 1 do
		hs.eventtap.event.newSystemKeyEvent('BRIGHTNESS_UP', true):post()
		hs.eventtap.event.newSystemKeyEvent('BRIGHTNESS_UP', false):post()
	end
end)

-- Illumination Down
hs.hotkey.bind(hs.settings.get('hotkeyCombo'), 'f1', function()
	hs.eventtap.event.newSystemKeyEvent('ILLUMINATION_DOWN', true):post()
	hs.eventtap.event.newSystemKeyEvent('ILLUMINATION_DOWN', false):post()
end)

-- Illumination Up
hs.hotkey.bind(hs.settings.get('hotkeyCombo'), 'f2', function()
	hs.eventtap.event.newSystemKeyEvent('ILLUMINATION_UP', true):post()
	hs.eventtap.event.newSystemKeyEvent('ILLUMINATION_UP', false):post()
end)

-- Location
-- if hs.location.servicesEnabled() and hs.location.authorizationStatus() == 'authorized' and hs.location.start() and hs.location.get() then
-- 	location = hs.location.get()
-- 	hs.settings.set('latitude', location.latitude)
-- 	hs.settings.set('longitude', location.longitude)
-- 	hs.location.register('updateLocationTag', function(locationTable)
-- 		hs.settings.set('latitude', locationTable.latitude)
-- 		hs.settings.set('longitude', locationTable.longitude)
-- 	end, 400)
-- else
-- 	-- hs.alert.show('⛅️Cannot retrieve lat/lng')
-- end

-- Google Query Suggestions
-- Based heavily on Andrew Hampton's "autocomplete"
-- https://github.com/andrewhampton/dotfiles/blob/8136fafe8aabee49f8cea0ab3da6c9e7be472e62/hammerspoon/.hammerspoon/anycomplete.lua
hs.hotkey.bind(hs.settings.get('hotkeyCombo'), 'G', function()
	local chooser = hs.chooser.new(function(choice)
		if not choice then return end
		hs.application.frontmostApplication():activate()
		hs.eventtap.keyStrokes(choice.text)
	end)
	chooser:queryChangedCallback(function(string)
		hs.http.asyncGet(string.format('https://suggestqueries.google.com/complete/search?client=chrome&num=5&q=%s', hs.http.encodeForQuery(string)), nil, function(status, data)
			if not data then return end
			local ok, results = pcall(function() return hs.json.decode(data) end)
			if not ok then return end
			choices = hs.fnutils.imap(results[2], function(result)
				return { ['text'] = result }
			end)
			chooser:choices(choices)
		end)
	end):searchSubText(false):show()
end)

-- New Google Calendar Event
hs.hotkey.bind(hs.settings.get('hotkeyCombo'), '8', function()
	hs.urlevent.openURL('https://calendar.google.com/calendar/r/eventedit')
end)

-- Dark Mode toggle
hs.hotkey.bind(hs.settings.get('hotkeyCombo'), 'f16', function()
	hs.osascript.applescript('tell application "System Events" to tell appearance preferences to set dark mode to not dark mode')
end)

-- -- Toggle Sidecar for iPad
-- hs.hotkey.bind(hs.settings.get('hotkeyCombo'), 'padenter', toggleSidecariPad)
-- hs.hotkey.bind(hs.settings.get('hotkeyCombo'), 'i', toggleSidecariPad)

-- DevTools Chooser
-- inspired by https://devutils.app/
devToolsList = {
	{
		text = 'GitHub Repositories (@rsefer)',
		image = hs.image.imageFromAppBundle('com.github.GitHubClient'),
		url = 'https://github.com/rsefer?tab=repositories'
	},
	{
		text = 'Meeting',
		image = hs.image.imageFromURL('https://flexibits.com/img/new-fantastical/logo/product/fantastical-mac-glyph@2x.png'),
		url = 'https://fantastical.app/rsefer/meeting'
	},
	{
		text = 'RegExr',
		image = hs.image.imageFromURL('https://regexr.com/assets/icons/favicon-32x32.png'),
		url = 'https://regexr.com'
	},
	{
		text = 'Unix Time Converter',
		image = hs.image.imageFromURL('https://dpidudyah7i0b.cloudfront.net/favicon.ico'),
		url = 'https://www.unixtimestamp.com'
	},
	{
		text = 'Character Count',
		image = hs.image.imageFromURL('https://wordcounter.net/favicon.ico'),
		action = 'countCharacters'
	},
	{
		text = 'Convert Case',
		image = hs.image.imageFromURL('https://convertcase.net/favicon.ico'),
		url = 'https://convertcase.net'
	},
	{
		text = 'Learn X in Y Minutes (JavaScript)',
		image = hs.image.imageFromURL('https://learnxinyminutes.com/favicon.ico'),
		url = 'https://learnxinyminutes.com/docs/javascript/'
	},
	{
		text = 'Hammerspoon Documentation',
		image = hs.image.imageFromAppBundle('org.hammerspoon.Hammerspoon'),
		url = 'https://www.hammerspoon.org/docs/index.html'
	},
	{
		text = 'Lorem Ipsum',
		image = hs.image.imageFromURL('https://loremipsum.io/assets/images/favicon.png'),
		action = 'loremIpsum'
	},
	{
		text = 'GenerateWP',
		image = hs.image.imageFromURL('https://generatewp.com/wp-content/uploads/cropped-generatewp-logo.png'),
		url = 'https://generatewp.com/generator/'
	},
	{
		text = 'Excalidraw',
		image = hs.image.imageFromURL('https://excalidraw.com/favicon.ico'),
		url = 'https://excalidraw.com/'
	}
}

function countCharacters()
	button, text = hs.dialog.textPrompt('Insert string to count', '')
	hs.alert('Given string has ' .. string.len(text) .. ' characters')
end

function loremIpsum()
	-- API from https://loripsum.net
	status, body, headers = hs.http.get('https://loripsum.net/api/1/short/plaintext') -- 1 paragraph, plaintext
	if not body then
		body = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'
	end
	hs.application.frontmostApplication():activate()
	hs.eventtap.keyStrokes(body)
end

hs.hotkey.bind(hs.settings.get('hotkeyCombo'), 'K', function()
	devToolsChooser = hs.chooser.new(function(choice)
		if not choice then return end
		if choice.action ~= nil then
			if choice.action == 'countCharacters' then
				countCharacters()
			elseif choice.action == 'loremIpsum' then
				loremIpsum()
			end
		else
			hs.urlevent.openURL(choice.url)
		end
	end):choices(devToolsList):show()
end)

-- Move tab to new window and minimize old
hs.hotkey.bind({'cmd', 'option', 'shift'}, 'T', function()
	local app = hs.application.frontmostApplication()
	if contains({
		'Google Chrome',
		'Safari'
	}, app:name()) then
		local workingTabMenu = 'Tab'
		if app:name() == 'Safari' then
			workingTabMenu = 'Window'
		end
		print(workingTabMenu)
		app:selectMenuItem({ workingTabMenu, 'Move Tab to New Window' })
		hs.eventtap.keyStroke({'cmd'}, '`')
		app:selectMenuItem({ 'Window', 'Minimize' })
	end
end)

-- Select note/text file to open
function promptForNote()
	hs.application.open('Obsidian', 3, true)
	hs.eventtap.keyStroke('cmd', 'o', hs.application.find('Obsidian')) -- bring up 'Open' dialog in Obsidian
	-- if not settingExists('notes_directory') then
	-- 	directories = hs.dialog.chooseFileOrFolder('Choose the Notes directory', '', false, true)
	-- 	if directories['1'] then
	-- 		hs.settings.set('notes_directory', directories['1'])
	-- 	else
	-- 		hs.alert('No directory selected')
	-- 		return
	-- 	end
	-- end

	-- files = {}
	-- local iterFn, dirObj = hs.fs.dir(hs.settings.get('notes_directory'))
	-- if not iterFn then return end
	-- for file in iterFn, dirObj do
	-- 	if string.sub(file, 1, 1) ~= '.' then
	-- 		table.insert(files, {
	-- 			fileName = file,
	-- 			filePath = hs.settings.get('notes_directory') .. '/' .. file,
	-- 			lastChange = hs.fs.attributes(hs.settings.get('notes_directory') .. '/' .. file, 'change')
	-- 		})
	-- 	end
	-- end
	-- if tablelength(files) == 0 then return end

	-- table.sort(files, function(a, b)
	-- 	return b.fileName > a.fileName -- alphabetical
	-- 	-- return a.lastChange > b.lastChange -- recently modified
	-- end)
	-- choices = {}
	-- for i, file in ipairs(files) do
	-- 	choice = file
	-- 	choice.image = textToImage('📄')
	-- 	choice.text = file.fileName:gsub('.txt', '')
	-- 	choice.subText = 'Last edited ' .. os.date('%B %d, %Y', file.lastChange)
	-- 	table.insert(choices, choice)
	-- end
	-- local chooser = hs.chooser.new(function(choice)
	-- 	if not choice then return end
	-- 	hs.execute('open ' .. choice.filePath:gsub(" ", "\\ "), true)
	-- end):width(30):choices(choices):show()
end

hs.hotkey.bind(hs.settings.get('hotkeyCombo'), ';', promptForNote)
hs.hotkey.bind(hs.settings.get('hotkeyCombo'), 'pad9', promptForNote)

-- -- Video Camera
-- local videoDimensions = { width = 800, height = 450, frame = hs.screen.primaryScreen():frame() }

-- local videoWebview = hs.webview.newBrowser(hs.geometry.rect((videoDimensions.frame.w / 2) - (videoDimensions.width / 2), (videoDimensions.frame.h / 2) - (videoDimensions.height / 2), videoDimensions.width, videoDimensions.height), {
-- 	developerExtrasEnabled = true,
-- 	plugInsEnabled = true
-- })
-- :shadow(true)
-- :titleVisibility('visible')
-- :allowTextEntry(true)
-- :windowCallback(function(action, webview, state)
-- 	if action == 'focusChange' and state ~= true and webview:isVisible() then
-- 		webview:evaluateJavaScript('togglePlayPause();'):hide()
-- 	end
-- end)
-- :url('https://rsefer.github.io/webcam-full/blank.html')
-- :hide()

-- hs.hotkey.bind(hs.settings.get('hotkeyCombo'), 'E', function()
-- 	if videoWebview:isVisible() then
-- 		videoWebview:hide():url('https://rsefer.github.io/webcam-full/blank.html')
-- 	else
-- 		videoWebview:url('https://rsefer.github.io/webcam-full/'):show():bringToFront(true)
-- 		videoWebview:hswindow():moveToScreen(hs.screen.primaryScreen()):focus()
-- 	end
-- end)
