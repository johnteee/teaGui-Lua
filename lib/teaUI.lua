package.path = package.path .. ";./?.lua"
local Object = require ( "object" )
local uiDriver = require( "uidriver" )
local Event = require( "event" )
local Component = require( "component" )
local shiftLeft, shiftRight, bor, band, min, max, fmod = bit.lshift, bit.rshift, bit.bor, bit.band, math.min, math.max, math.fmod

local teaUI = Component:extend{
	className = "teaUI",
	
	--Control
	uiDriver = nil,
	
	hotItem = 0, activeItem = 0,
	kbdItem = 0, lastWidget = 0,
	tabSwitch = true,
	
	isShoudExit = false,
	element = nil,
	
	loopDelay = 10,
	canFocusOn = false,
	canEventOn = true,
	
	--Layout
	width = 800, height = 600,
	backgroundColor = 0x77,
	fontWidth = 14, fontHeight = 24,
	fontRequire = "font14x24",
	
	title = "This is a test"
}

function teaUI:create()
	local newone = self:new()
	
	newone:init() -- Initialize
	
	return newone
end

function teaUI:init()
	--Control
	self.hotItem = 0
	self.activeItem = 0
	self.kbdItem = 0
	self.lastWidget = 0
	self.tabSwitch = true
	
	self.isShoudExit = false
	
	self.loopDelay = 10
	
	--Layout
	self.width = 800
	self.height = 600
	self.backgroundColor = 0x77
	self.title = "This is a test"
	
	--Env
	self.uiDriver = uiDriver:new()
	self.uiDriver:init()
	
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
	return self:CurrentLine()
end

function teaUI:regionHit( x, y, w, h )
	local evt = self:getEvent()
	return ( evt.mouseX >= x and
		evt.mouseY >= y and
		evt.mouseX <= x + w and
		evt.mouseY <= y + h )
end

function teaUI:paint()
	self:drawRect( 0, 0, self.width, self.height, self.backgroundColor )
	self:drawString( self.title, 10, 10 )
	
	local el = self.element
	
	do
		for i=1, #el do
			local comp = el[ i ]
			comp:paint()
		end
	end
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
	local platformConst = self:getPlatformConst()
	local eventTypeConst = self:getEventTypeConst()
	
	local eventType = self:super().handleEvent ( self, evt )
	
	if driver:isKeyEntered( evt, platformConst.ESCAPE ) then
		self.isShoudExit = true
	end
	
	if self:isEventType( evt, eventTypeConst.QUIT ) then
		self:onQuit( evt )
	end
	
	self:handleComponent()
end

function teaUI:detectEvent( evt )
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
	return self.hotItem == comp.ID
end

function teaUI:isMousePress( comp )
	return self.activeItem == comp.ID
end

function teaUI:isFocusOn( comp )
	return self.kbdItem == comp.ID
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
	self.hotItem = comp.ID
end

function teaUI:focusOn( comp )
	if comp.canFocusOn == true then
		self.kbdItem = comp.ID
	end
end

function teaUI:pressOn( comp )
	self.activeItem = comp.ID
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
		self:hoverOn( comp )
		if self:isNoOnePressed() and evt.mouseDown then
			self:pressOn( comp )
			self:focusOn( comp )
		end
	end
	
	if self:isNoOneFocusOn() then
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
	self.hotItem = 0
end

function teaUI:guiFinish()
	local evt = self:getEvent()
	local driver = self:getUIDriver()
	local platformConst = self:getPlatformConst()
	
	if not evt.mouseDown then
		self:releasePress()
	elseif self.activeItem == 0 then
		self.activeItem = -1
	end
	
	if driver:isKeyEntered( evt, platformConst.TAB ) then
		self.kbditem = 0
	end
	evt.keyEntered = 0
	evt.keyChar = 0
end

function teaUI:handleComponent()
	local el, evt = self.element, self:getEvent()
	
	self:guiPrepare()
	do
		for i=1, #el do
			local comp = el[ i ]
			comp:handleEvent( evt )
		end
	end
	self:guiFinish()
end

function teaUI:onQuit( evt )
	self.isShoudExit = true
end

function teaUI:mainLoop()
	local driver = self:getUIDriver()
	while not self.isShoudExit do
		while driver:isAnyEvent() do -- If non-Event, then repaint only
			self:handleEvent( driver.rawEvent ) -- Detect rawEvent
		end
		self:paint() -- Render
		
		self:refresh()
		
		self:sleep( self.loopDelay ) -- Delay
	end
	
	driver:quit() -- Do Exit
end

function teaUI:start()
	self:mainLoop() -- Main Loop
end

return teaUI