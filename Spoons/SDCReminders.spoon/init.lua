--- === SDC Reminders ===
local obj = {}
obj.__index = obj
obj.name = "SDCReminders"

function script_path()
  local str = debug.getinfo(2, 'S').source:sub(2)
  return str:match("(.*/)")
end

local viewWidth = 1000
local viewHeight = 700

function obj:setHTML()
	local indexHTML = ''
	for line in io.lines(script_path() .. "index.html") do indexHTML = indexHTML .. line .. "\n" end
	obj.remindersWebview:html(indexHTML)
end

function obj:toggleWebview()
  if obj.isShown then
    obj.remindersWebview:hide()
    obj.isShown = false
  else
		obj.remindersWebview:reload()
		obj:setHTML()
    obj.remindersWebview:show():bringToFront(true)
		obj.remindersWebview:hswindow():moveToScreen(hs.screen.primaryScreen()):focus()
    obj.isShown = true
  end
end

function obj:bindHotkeys(mapping)
  local def = {
    toggleWebview = hs.fnutils.partial(self.toggleWebview, self)
  }
  hs.spoons.bindHotkeysToSpec(def, mapping)
end

function obj:init()

  self.isShown = false
	local frame = hs.screen.primaryScreen():frame()
  self.rect = hs.geometry.rect((frame.w / 2) - (viewWidth / 2), (frame.h / 2) - (viewHeight / 2), viewWidth, viewHeight)
  self.remindersJS = hs.webview.usercontent.new('idhsremindersWebview'):setCallback(function(message)
		if message.body.reminder ~= nil then
			local reminder = message.body.reminder
			output, status, type, rc = hs.execute('osascript ' .. script_path() .. 'new-reminder.scpt "' .. reminder.name .. '" "' .. reminder.list .. '" "' .. reminder.date .. ' ' .. reminder.time .. '"')
			if status then
				obj:toggleWebview()
			end
		end
  end)
  self.remindersWebview = hs.webview.newBrowser(self.rect, { developerExtrasEnabled = true }, self.remindersJS)
    :allowTextEntry(true)
    :shadow(true)
		:windowCallback(function(action, webview, state)
			if action == 'focusChange' and state ~= true then
				self.remindersWebview:hide()
		    self.isShown = false
			end
		end)
	self:setHTML()

end

return obj
