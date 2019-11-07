--- === SDC Windows ===
local obj = {}
obj.__index = obj
obj.name = "SDCWindows"

function obj:appFrameSet(layout, app)
	if app == nil then
		app = hs.application.frontmostApplication()
	end
	hs.layout.apply({
		{
			app:name(),
			app:focusedWindow(),
			app:focusedWindow():screen(),
			layout
		}
	})
end

function obj:bindHotkeys(mapping)
  local def = {
		resetWindows = function()
			hs.layout.apply(obj.windowLayout)
		end,
		sizeLeftHalf = function()
			obj:appFrameSet(hs.layout.left50)
		end,
		sizeRightHalf = function()
			obj:appFrameSet(hs.layout.right50)
		end,
		sizeFull = function()
			obj:appFrameSet(hs.layout.maximized)
		end,
		sizeCentered = function()
			obj:appFrameSet(hs.geometry.unitrect(hs.settings.get('windowSizes').sizeCentered))
		end,
		sizeLeft34ths = function()
			obj:appFrameSet(hs.geometry.unitrect(hs.settings.get('windowSizes').sizeLeft34ths))
		end,
		size34thsCentered = function()
			obj:appFrameSet(hs.geometry.unitrect(hs.settings.get('windowSizes').size34thsCentered))
		end,
		sizeRight14th = function()
			obj:appFrameSet(hs.geometry.unitrect(hs.settings.get('windowSizes').sizeRight14th))
		end,
		sizeRight14thTopHalfish = function()
			obj:appFrameSet(hs.geometry.unitrect(hs.settings.get('windowSizes').sizeRight14thTopHalfish))
		end,
		sizeRight14thBottomHalfish = function()
			obj:appFrameSet(hs.geometry.unitrect(hs.settings.get('windowSizes').sizeRight14thBottomHalfish))
		end,
		sizeHalfHeightTopEdge = function()
			win = hs.window:focusedWindow()
			win:setFrame(hs.geometry.rect(win:frame().x, 0.00, win:frame().w, win:screen():frame().h / 2))
		end,
		sizeHalfHeightBottomEdge = function()
			win = hs.window:focusedWindow()
			win:setFrame(hs.geometry.rect(win:frame().x, win:screen():fullFrame().h / 2, win:frame().w, win:screen():fullFrame().h / 2))
		end,
		moveLeftEdge = function()
			win = hs.window:focusedWindow()
			win:setFrame(hs.geometry.rect(win:screen():frame().x, win:frame().y, win:frame().w, win:frame().h))
		end,
		moveRightEdge = function()
			win = hs.window:focusedWindow()
			win:setFrame(hs.geometry.rect(win:screen():fullFrame().w - win:frame().w, win:frame().y, win:frame().w, win:frame().h))
		end
  }
  hs.spoons.bindHotkeysToSpec(def, mapping)
end

function obj:init()

  hs.window.animationDuration = 0
  hs.window.setFrameCorrectness = true
  hs.grid.MARGINX = 0
  hs.grid.MARGINY = 0
  hs.grid.GRIDWIDTH = 10
  hs.grid.GRIDHEIGHT = 10

	self.applicationWatcher = nil

end

function obj:start()

	self.applicationWatcher = hs.application.watcher.new(function(name, event, app)
		if event == 1 or event == hs.application.watcher.launched then
			for k, ao in ipairs(self.windowLayout) do
				if name == ao[1] then
					hs.timer.doAfter(2, function()
						hs.layout.apply({ ao })
					end)
					break
				end
			end
		end
  end):start()

  return self
end

function obj:stop()
  self.applicationWatcher:stop()
  return self
end

return obj
