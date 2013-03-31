package.path = package.path .. ";./?.lua"
local Object = require ( "object" )
local ffi = require( "ffi" )
local sdl = require( "ffi/sdl" )
local Event = require( "event" )
local shiftLeft, shiftRight, bor, band, min, max = bit.lshift, bit.rshift, bit.bor, bit.band, math.min, math.max

local teaUI = Object:new{
	--Control
	event = nil,
	
	hotItem = 0, activeItem = 0,
	kbdItem = 0, lastWidget = 0,
	
	isShoudExit = false,
	element = nil,
	
	--Layout
	screenWidth = 800, screenHeight = 600,
	backgroundColor = 0x77
}

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
	evt.keyMod = false 
	
	self.hotItem = 0
	self.activeItem = 0
	self.kbdItem = 0
	self.lastWidget = 0
	
	self.isShoudExit = false
	
	--Layout
	self.screenWidth = 800
	self.screenHeight = 600
	self.backgroundColor = 0x77
	
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

function teaUI:makeFont( data )
end

function teaUI:loadFont( name )
	local file = sdl.SDL_RWFromFile(name .. ".bmp", "rb")
	local temp = sdl.SDL_LoadBMP_RW(file, 1)
	local font = sdl.SDL_ConvertSurface( temp, self.screen.format, sdl.SDL_SWSURFACE )
	sdl.SDL_FreeSurface( temp )
	sdl.SDL_SetColorKey( font, sdl.SDL_SRCCOLORKEY, 0 )
	return font
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
end

function teaUI:render()
	self:drawRect( 0, 0, self.screenWidth, self.screenHeight, self.backgroundColor )
	self:drawString( "0DDTest1238919283891289319823123", 10, 10 )
end

function teaUI:refresh()
	sdl.SDL_UpdateRect( self.screen, 0, 0, self.screenWidth, self.screenHeight )
end

function teaUI:randomBgColor()
	self.backgroundColor = bor( sdl.SDL_GetTicks() * 0xc0cac01a, 0x77 )
end

function teaUI:quit()
	self.isShoudExit = true
end

function teaUI:sleep( msec )
	sdl.SDL_Delay( msec )
end

function teaUI:detectEvent( rawEvent )
	local evttype, key, mod = rawEvent.type, rawEvent.key.keysym.sym, rawEvent.key.keysym.mod
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
		evt.keyMod = mod
	elseif evttype == sdl.SDL_KEYUP then
		if key == sdl.SDLK_ESCAPE then
			self.isShoudExit = true
		elseif key == sdl.SDLK_F1 then
			self.backgroundColor = bor( sdl.SDL_GetTicks() * 0xc0cac01a, 0x77 )
		end
	end
end

function teaUI:isMouseHover( theID )
	return self.hotItem == theID
end

function teaUI:isMousePress( theID )
	return self.activeItem == theID
end

function teaUI:isFocusOn( theID )
	return self.kbdItem == theID
end

function teaUI:isNoOneFocusOn()
	return self:isFocusOn( 0 )
end

function teaUI:isNoOnePressed()
	return self:isMousePress( 0 )
end

function teaUI:getLastWidget()
	return self.lastWidget
end

function teaUI:hoverOn( theID )
	self.hotItem = theID
end

function teaUI:focusOn( theID )
	self.kbdItem = theID
end

function teaUI:pressOn( theID )
	self.activeItem = theID
end

function teaUI:releaseFocus()
	self:focusOn( 0 )
end

function teaUI:checkHitOn( theID, x, y, width, height )
	local evt = self:getEvent()
	if self:regionHit( x, y, width, height ) then
		self:hoverOn( theID )
		if self:isNoOnePressed() and evt.mouseDown then
			self:pressOn( theID )
			self:focusOn( theID )
		end
	end
	
	if self:isNoOneFocusOn() then
		self:focusOn( theID )
	end
end

function teaUI:checkSwitchFocus( theID )
	local evt = self:getEvent()
	if self:isFocusOn( theID ) then
		if evt.keyEntered == sdl.SDLK_TAB then
				self:releaseFocus()
				if band( evt.keyMod, sdl.KMOD_SHIFT ) then
					self:focusOn( self:getLastWidget() )
				end
				evt.keyEntered = 0
		end
	end
	
	self.lastWidget = theID;
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
		self:render() -- Render
		self:handleComponent()
		self:refresh()
		
		self:sleep( 10 ) -- Delay
	end
	
	sdl.SDL_Quit() -- Do Exit
end

function teaUI:start()
	self:init() -- Initialize
	self:mainLoop() -- Main Loop
end

return teaUI