package.path = package.path .. ";../?.lua;?.lua;lib/?.lua"

local Object = require ( "lib.object" )
local Event = require( "lib.event" )
local Component = require( "lib.component" )
local shiftLeft, shiftRight, bor, band, min, max, fmod = bit.lshift, bit.rshift, bit.bor, bit.band, math.min, math.max, math.fmod

local teaUI = Component:extend{
	className = "teaUI", --Class Name
	
	--Control
	uiDriver = nil,
	
	hoverItem = 0, pressedItem = 0,
	focusOnItem = 0, lastWidget = 0,
	tabSwitch = true, --Can us TAB key switch focus
	
	isShoudExit = false, --Main Loop Exit control
	element = nil, --Components container
	
	loopDelay = 10, --sleep time in each loop
	canFocusOn = false, --Can focus on?
	canEventOn = true, --Can Event handling?
	canHoverOn = false, --Can Hover On -->but teaUI have no need and must be disabled
	showFPS = false,
	
	--Layout
	width = 800, height = 600, --That's screen width and height
	backgroundColor = 0x77, -- BgColor
	fullScreen = false, --Full Screen Mode
	nativeResolutionFullScreen = true,
	
	fontWidth = 14, fontHeight = 24, --font
	fontRequire = "font14x24",
	
	title = "This is a test" --Caption for test
}

function teaUI:create( uiDriver, width, height, fullScreen, nativeResolutionFullScreen )
	local newOne = self:new()
	
	newOne.width = width or newOne.width
	newOne.height = height or newOne.height
	newOne.fullScreen = fullScreen or newOne.fullScreen
	newOne.nativeResolutionFullScreen = nativeResolutionFullScreen or newOne.nativeResolutionFullScreen
	newOne.uiDriver = uiDriver
	
	newOne:init() -- Initialize
	
	return newOne
end

function teaUI:init()
	--Control
	self.isShoudExit = false
	
	self.loopDelay = 10
	
	--Layout
	self.backgroundColor = 0x77
	self.title = "This is a test"
	
	--Env
	self.uiDriver.width = self.width
	self.uiDriver.height = self.height
	self.uiDriver.nativeResolutionFullScreen = self.nativeResolutionFullScreen
	self.uiDriver.fullScreen = self.fullScreen
	self.uiDriver:init()
	self.width = self.uiDriver.width
	self.height = self.uiDriver.height
	
	self.timestamp = self:getUIDriver():getTimestamp()
	
	self.parent = self
	self.ID = self:GenID()
	
	--Element
	self:initElement()
end

function teaUI:initElement ()
	self.element = self.element or {}
end

function teaUI:loadBitmap ( path )
	return self:getUIDriver():loadBitmap( path )
end

function teaUI:drawCharCode( charcode, x, y )
	self:getUIDriver():drawCharCode( charcode, x, y )
end

function teaUI:drawImage( img, x, y, width, height )
	self:getUIDriver():drawImage( img, x, y, width, height )
end

function teaUI:drawRect( x, y, w, h, color )
	self:getUIDriver():drawRect( x, y, w, h, color )
end

function teaUI:drawRectWire( x, y, w, h, color, alpha)
	self:getUIDriver():drawRectWire( x, y, w, h, color, alpha)
end

function teaUI:drawString( s, x, y )
	for i=1, #s do
		self:drawCharCode( s:byte(i), x, y )
		x = x + self.fontWidth
	end
end

function teaUI:addComponent( comp )
	self:initElement()
	local el = self.element
	el[ #el + 1 ] = comp
	comp.parent = self
end

function teaUI:CurrentLine()
	return debug.getinfo(2, "l").currentline
end

function teaUI:GenID()
	self.snID = self.snID or 0
	self.snID = self.snID + 1
	return self.snID
	--return self:CurrentLine()
end

function teaUI:regionHit( x, y, w, h )
	local evt = self:getEvent()
	return ( evt.mouseX >= x and
		evt.mouseY >= y and
		evt.mouseX <= x + w and
		evt.mouseY <= y + h )
end

function teaUI:paint()
	local title = self.title
	local oldtimestamp = self.timestamp
	
	if oldtimestamp == nil then
		self.timestamp = self:getUIDriver():getTimestamp()
	elseif self.showFPS then
		self.timestamp = self:getUIDriver():getTimestamp()
		title = string.format( "%s\tFPS: %0.2f", title, 1000/(self.timestamp - oldtimestamp) )
	end
	
	self:drawRect( 0, 0, self.width, self.height, self.backgroundColor )
	self:drawString( title, 10, 10 )
	-- self:setTitle( self.title )
	
	local el = self.element
	
	do
		for i=1, #el do
			local comp = el[ i ]
			comp:paint()
		end
	end
end

function teaUI:setTitle( title )
	self:getUIDriver():setWindowTitle( title )
end

function teaUI:toggleFullScreen()
	self:getUIDriver():toggleFullScreen()
end

function teaUI:refresh()
	self:getUIDriver():refresh()
end

function teaUI:randomBgColor()
	self.backgroundColor = self:getUIDriver():randomColor()
end

function teaUI:isShowCursorNow()
	return self:getUIDriver():isShowCursorNow()
end

function teaUI:sleep( msec )
	self:getUIDriver():sleep( msec )
end

function teaUI:setTitle( str )
	self.title = str
end

function teaUI:quit()
	self.isShoudExit = true
end

function teaUI:handleEvent( rawEvent )
	local driver = self:getUIDriver()
	local evt = driver:handleRawEvent( rawEvent )
	
	self:guiPrepare() --Clean some status
	
	--Handle components first
	self:handleComponent()
	
	--Handle teaUI itself events
	local platformConst = self:getPlatformConst()
	local eventTypeConst = self:getEventTypeConst()
	
	local eventArray, valueArray = self:super().handleEvent ( self, evt )
	
	if driver:isKeyEntered( evt, platformConst.ESCAPE ) then
		self.isShoudExit = true
	end
	
	if self:isEventType( evt, eventTypeConst.QUIT ) then
		self:onQuit( evt )
	end
	
	self:guiFinish() --Clean some status
end

function teaUI:detectEvent( evt )
	-- if self:isNoOnePressed() and evt.mouseDown then
			-- self:pressOn( self )
			-- self:focusOn( self )
	-- end
	self:setHitRegion( self.x, self.y, self.width, self.height )
	
	self:checkHitOn( self, self.hitRegion.x, self.hitRegion.y, self.hitRegion.width, self.hitRegion.height )
	self:checkSwitchFocus( self )
	
	local driver = self:getUIDriver()
	local eventtype = self:getEventTypeConst()
	local platformConst = self:getPlatformConst()
	
	local eventArray, valueArray = {}, {}
	eventArray.empty = true
	
	--System
	if driver:isEventType( evt, eventtype.QUIT ) then
		eventArray["quit"] = "quit"
		valueArray["quit"] = "quit"
		eventArray.empty = false
	--Mouse
	elseif driver:isEventType( evt, eventtype.MOUSEMOTION ) then
		eventArray["mousemotion"] = "mousemotion"
		valueArray["mousemotion"] = "mousemotion"
		eventArray.empty = false
	elseif driver:isEventType( evt, eventtype.MOUSEBUTTONDOWN ) then
		eventArray["mousedown"] = "mousedown"
		valueArray["mousedown"] = "mousedown"
		eventArray.empty = false
	elseif driver:isEventType( evt, eventtype.MOUSEBUTTONUP ) then
		eventArray["mouseup"] = "mouseup"
		valueArray["mouseup"] = "mouseup"
		eventArray.empty = false
	--KeyBoard
	elseif driver:isEventType( evt, eventtype.KEYDOWN ) then
		eventArray["keydown"] = "keydown"
		valueArray["keydown"] = "keydown"
		eventArray.empty = false
	elseif driver:isEventType( evt, eventtype.KEYUP ) then
		eventArray["keyup"] = "keyup"
		valueArray["keyup"] = "keyup"
		eventArray.empty = false
	end
	
	if( eventArray.empty == false ) then
		return eventArray, valueArray
	end
	
	return { ["nothing"] = "nothing" }, { ["nothing"] = "nothing" }
end

function teaUI:isMouseHover( comp )
	return self.hoverItem == comp.ID
end

function teaUI:isMousePress( comp )
	return self.pressedItem == comp.ID
end

function teaUI:isFocusOn( comp )
	return self.focusOnItem == comp.ID
end

function teaUI:isNoOneFocusOn()
	return self:isFocusOn( Component:new() )
end

function teaUI:isNoOnePressed()
	return self:isMousePress( Component:new() )
end

function teaUI:getLastWidget()
	return self.lastWidget
end

function teaUI:hoverOn( comp )
	self.hoverItem = comp.ID
end

function teaUI:focusOn( comp )
	if comp.canFocusOn == true then
		self.focusOnItem = comp.ID
	end
end

function teaUI:pressOn( comp )
	self.pressedItem = comp.ID
end

function teaUI:releaseFocus()
	self:focusOn( Component:new() )
end

function teaUI:releasePress()
	self:pressOn( Component:new() )
end

function teaUI:checkHitOn( comp, x, y, width, height )
	if comp.canEventOn == false then
		return
	end
	
	local evt = self:getEvent()
	if self:regionHit( x, y, width, height ) then
		if comp.canHoverOn then
			self:hoverOn( comp )
		end
		
		if self:isNoOnePressed() and evt.mouseDown then
			self:pressOn( comp )
			self:focusOn( comp )
		end
	end
	
	--If no one has get focus or it has been hovered on and canHoverFocus, then gets the focus
	if self:isNoOneFocusOn() or ( comp.canHoverFocus == true and self:isMouseHover( comp ) ) then
		self:focusOn( comp )
	end
end

function teaUI:checkSwitchFocus( comp )
	if comp.canFocusOn == false then
		return
	end
	
	local evt = self:getEvent()
	local keyconst = self:getPlatformConst()
	local driver = self:getUIDriver()
	
	if self:isFocusOn( comp ) and self.tabSwitch then
		if driver:isKeyEntered( evt, keyconst.TAB ) then
				self:releaseFocus()
				if driver:isKeyMod( evt, keyconst.KEYMODESHIFT ) then
					self:focusOn( Component:new{ ID=self:getLastWidget() } )
				end
				evt.keyEntered = 0
				evt.keyChar = 0
		end
	end
	
	self.lastWidget = comp.ID;
end

function teaUI:getEvent()
	return self:getUIDriver().event
end

function teaUI:getPlatformConst()
	return self:getUIDriver().platformConst
end

function teaUI:getEventTypeConst()
	return self:getUIDriver().eventTypeConst
end

function teaUI:getUIDriver()
	return self.uiDriver
end

function teaUI:isKeyMod( evt, keyMod )
	return self:getUIDriver():isKeyMod( evt, keyMod )
end

function teaUI:isKeyEntered( evt, key )
	return self:getUIDriver():isKeyEntered( evt, key )
end

function teaUI:isEventType( evt, eventType )
	return self:getUIDriver():isEventType( evt, eventType )
end

function teaUI:guiPrepare()
	self.hoverItem = 0
end

function teaUI:guiFinish()
	local evt = self:getEvent()
	local driver = self:getUIDriver()
	local platformConst = self:getPlatformConst()
	
	if not evt.mouseDown then
		self:releasePress()
	elseif self.pressedItem == 0 then
		self.pressedItem = -1
	end
	
	if driver:isKeyEntered( evt, platformConst.TAB ) then
		self.focusOnItem = 0
	end
	evt.keyEntered = 0
	evt.keyChar = 0
end

function teaUI:handleComponent()
	local el, evt = self.element, self:getEvent()
	
	do
		for i=1, #el do
			local comp = el[ i ]
			comp:handleEvent( evt ) --Handle component events
		end
	end
end

function teaUI:onQuit( evt )
	self.isShoudExit = true
end

function teaUI:printCoError( co, errorMsg )
	local inCoMsg
	if errorMsg ~= nil then
		inCoMsg = "\n\nIn coroutine:" .. errorMsg
	else
		inCoMsg = "\n\nUnknown Error"
	end
	error( string.format( "%s\n%s\n\nIn calling thread:", inCoMsg, debug.traceback( co ) ) )
end

function teaUI:createEventThreadAndStart( theFunc, myself, evt )
	local co = coroutine.create( theFunc )
	local coStatus, errorMsg = false, nil
	
	coStatus, errorMsg = coroutine.resume( co, myself, evt )
	
	if coStatus == false then
		teaUI:printCoError( co, errorMsg )
	end
	
	return co
end

function teaUI:createSimpleThreadAndStart( theFunc, myself )
	local co = coroutine.create( theFunc )
	local coStatus,errMsg = false, nil
	
	if myself ~= nil then
		coStatus, errMsg = coroutine.resume( co, myself )
	else
		coStatus, errMsg = coroutine.resume( co )
	end
	
	if coStatus == false then
		teaUI:printCoError( co, errorMsg )
	end
	
	return co
end

function teaUI:pollingAndHandlingEvent()
	local driver = self:getUIDriver()
	
	while driver:isAnyEvent() do -- If non-Event, then repaint only
		self:handleEvent( driver.rawEvent ) -- Detect rawEvent
	end
end

function teaUI:mainLoop()
	local driver = self:getUIDriver()
	
	while not self.isShoudExit do
		self:createSimpleThreadAndStart( self.pollingAndHandlingEvent, self ) --Polling & Handling Events
		
		self:createSimpleThreadAndStart( self.paint, self ) -- Render
		
		self:refresh()
		
		self:sleep( self.loopDelay ) -- Delay
	end
	
	driver:quit() -- Do Exit
end

function teaUI:start()
	self:mainLoop() -- Main Loop
end

return teaUI