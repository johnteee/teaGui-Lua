package.path = package.path .. ";./?.lua"
local Object = require ( "object" )
local ffi = require( "ffi" )
local sdl = require( "ffi/sdl" )
local Event = require( "event" )
local Component = require( "component" )
local shiftLeft, shiftRight, bor, band, min, max = bit.lshift, bit.rshift, bit.bor, bit.band, math.min, math.max

local teaUI = Object:new{
	--Control
	event = nil,
	
	hotItem = 0, activeItem = 0,
	kbdItem = 0, lastWidget = 0,
	tabSwitch = true,
	
	isShoudExit = false,
	element = nil,
	
	loopDelay = 10,
	
	--Layout
	screenWidth = 800, screenHeight = 600,
	backgroundColor = 0x77,
	fontWidth = 14, fontHeight = 24,
	title = "This is a test"
}

function teaUI:create()
	local newone = self:new()
	
	newone:init() -- Initialize
	
	return newone
end

function teaUI:init()
	--Env
	sdl.SDL_EnableKeyRepeat( sdl.SDL_DEFAULT_REPEAT_DELAY, sdl.SDL_DEFAULT_REPEAT_INTERVAL )
	sdl.SDL_EnableUNICODE(1)
	self.screen = sdl.SDL_SetVideoMode( self.screenWidth, self.screenHeight, 32, 0 )
	self.font = self:requireFont( "font14x24" )
	self.rawEvent = ffi.new( "SDL_Event" )
	self.rectFg, self.rectBg = ffi.new( "SDL_Rect" ), ffi.new( "SDL_Rect" )
	
	--Control
	self.event = Event:new()
	local evt = self:getEvent()
	evt.mouseDown = false
	evt.mouseX = 0
	evt.mouseY = 0
	evt.keyEntered = 0
	evt.keyChar = 0
	evt.keyMod = false 
	
	self.hotItem = 0
	self.activeItem = 0
	self.kbdItem = 0
	self.lastWidget = 0
	self.tabSwitch = true
	
	self.isShoudExit = false
	
	self.loopDelay = 10
	
	--Layout
	self.screenWidth = 800
	self.screenHeight = 600
	self.backgroundColor = 0x77
	self.fontWidth = 14
	self.fontHeight = 24
	self.title = "This is a test"
	
	--Element
	self:initElement()
end

function teaUI:initElement ()
	self.element = self.element or {}
end

function teaUI:addComponent( comp )
	self:initElement()
	local el = self.element
	el[ #el + 1 ] = comp
	comp.parent = self
end

function teaUI:loadBitmap ( path )
	local file = sdl.SDL_RWFromFile( path, "rb")
	local temp = sdl.SDL_LoadBMP_RW(file, 1)
	local img = sdl.SDL_ConvertSurface( temp, self.screen.format, sdl.SDL_SWSURFACE )
	sdl.SDL_FreeSurface( temp )
	sdl.SDL_SetColorKey( img, sdl.SDL_SRCCOLORKEY, 0 )
	return img
end

function teaUI:requireFont( name )
	local font = require( "font/" .. name )
	local data = ffi.new( "uint8_t[?]", #font, font )
	local file = sdl.SDL_RWFromConstMem( data, ffi.sizeof(data) )
	local temp = sdl.SDL_LoadBMP_RW(file, 1)
	local font = sdl.SDL_ConvertSurface( temp, self.screen.format, sdl.SDL_SWSURFACE )
	sdl.SDL_FreeSurface( temp )
	sdl.SDL_SetColorKey( font, sdl.SDL_SRCCOLORKEY, 0 )
	return font
end

function teaUI:CurrentLine()
	return debug.getinfo(2, "l").currentline
end

function teaUI:GenID()
	return self:CurrentLine()
end

function teaUI:drawCharCode( charcode, x, y )
	self.rectFg.x, self.rectFg.y, self.rectFg.w, self.rectFg.h = 0, (charcode - 32) * 24, 14, 24
	self.rectBg.x, self.rectBg.y, self.rectBg.w, self.rectBg.h = x, y, 14, 24
	-- sdl.SDL_BlitSurface( self.font, self.rectFg, self.screen, self.rectBg )
	sdl.SDL_UpperBlit( self.font, self.rectFg, self.screen, self.rectBg )
end

function teaUI:drawImage( img, x, y, width, height )
	self.rectFg.x, self.rectFg.y, self.rectFg.w, self.rectFg.h = 0, 0, width or img.w, height or img.h
	self.rectBg.x, self.rectBg.y, self.rectBg.w, self.rectBg.h = x, y, width or img.w, height or img.h
	-- sdl.SDL_BlitSurface( img, self.rectFg, self.screen, self.rectBg )
	sdl.SDL_UpperBlit( img, self.rectFg, self.screen, self.rectBg )
end

function teaUI:drawString( s, x, y )
	for i=1, #s do
		self:drawCharCode( s:byte(i), x, y )
		x = x + 14
	end
end

function teaUI:drawRect( x, y, w, h, color )
	self.rectFg.x, self.rectFg.y, self.rectFg.w, self.rectFg.h = x, y, w, h
	sdl.SDL_FillRect( self.screen, self.rectFg, color )
end

function teaUI:regionHit( x, y, w, h )
	local evt = self:getEvent()
	return ( evt.mouseX >= x and
		evt.mouseY >= y and
		evt.mouseX <= x + w and
		evt.mouseY <= y + h )
end

function teaUI:guiPrepare()
	self.hotItem = 0
end

function teaUI:guiFinish()
	local evt = self:getEvent()
	if not evt.mouseDown then
		self.activeItem = 0
	elseif self.activeItem == 0 then
		self.activeItem = -1
	end
	
	if evt.keyEntered == SDLK_TAB then
		self.kbditem = 0
	end
	evt.keyEntered = 0
	evt.keyChar = 0
end

function teaUI:render()
	self:drawRect( 0, 0, self.screenWidth, self.screenHeight, self.backgroundColor )
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
	sdl.SDL_UpdateRect( self.screen, 0, 0, self.screenWidth, self.screenHeight )
end

function teaUI:setTitle( str )
	self.title = str
end

function teaUI:randomBgColor()
	self.backgroundColor = bor( sdl.SDL_GetTicks() * 0xc0cac01a, 0x77 )
end

function teaUI:isShowCursorNow()
	return band(shiftRight(sdl.SDL_GetTicks(), 8), 1)
end

function teaUI:quit()
	self.isShoudExit = true
end

function teaUI:sleep( msec )
	sdl.SDL_Delay( msec )
end

function teaUI:detectEvent( rawEvent )
	local evttype, key, keymod, keyunicode = rawEvent.type, rawEvent.key.keysym.sym, rawEvent.key.keysym.mod, rawEvent.key.keysym.unicode
	local motion, button = rawEvent.motion, rawEvent.button.button
	local evt = self:getEvent()
	--System
	if evttype == sdl.SDL_QUIT then
		self.isShoudExit = true
	--Mouse
	elseif evttype == sdl.SDL_MOUSEMOTION then
		evt.mouseX, evt.mouseY = motion.x, motion.y
	elseif evttype == sdl.SDL_MOUSEBUTTONDOWN and button == 1 then
		evt.mouseDown = true
	elseif evttype == sdl.SDL_MOUSEBUTTONUP and button == 1 then
		evt.mouseDown = false
	--KeyBoard
	elseif evttype == sdl.SDL_KEYDOWN then
		evt.keyEntered = key
		evt.keyMod = keymod
		if band(keyunicode, 0xFF80) == 0 then
			evt.keyChar = band(keyunicode, 0x7F);
		end
		
		if key == sdl.SDLK_q and band( evt.keyMod, sdl.KMOD_CTRL )  then
			self.isShoudExit = true
		end
	elseif evttype == sdl.SDL_KEYUP then
		
	end
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
	if self:isFocusOn( comp ) and self.tabSwitch then
		if evt.keyEntered == sdl.SDLK_TAB then
				self:releaseFocus()
				if band( evt.keyMod, sdl.KMOD_SHIFT ) then
					self:focusOn( Component:new{ ID=self:getLastWidget() } )
				end
				evt.keyEntered = 0
				evt.keyChar = 0
		end
	end
	
	self.lastWidget = comp.ID;
end

function teaUI:getEvent()
	return self.event
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

function teaUI:mainLoop()
	while not self.isShoudExit do
		while sdl.SDL_PollEvent( self.rawEvent ) ~= 0 do -- If non-rawEvent, then repaint only
			self:detectEvent( self.rawEvent ) -- Detect rawEvent
		end
		self:handleComponent()
		self:render() -- Render
		
		self:refresh()
		
		self:sleep( self.loopDelay ) -- Delay
	end
	
	sdl.SDL_Quit() -- Do Exit
end

function teaUI:start()
	self:mainLoop() -- Main Loop
end

return teaUI