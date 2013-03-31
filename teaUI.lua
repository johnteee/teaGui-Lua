local Object = require ( "object" )
local ffi = require( "ffi" )
local sdl = require( "ffi/sdl" )
local Event = require( "event" )
local shiftLeft, shiftRight, bor, band, min, max = bit.lshift, bit.rshift, bit.bor, bit.band, math.min, math.max
local rect, rect2 = ffi.new( "SDL_Rect" ), ffi.new( "SDL_Rect" )

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
	
	--Control
	self.event = Event:new()
	self.event.mouseDown = false
	self.event.mouseX = 0
	self.event.mouseY = 0
	self.event.keyEntered = 0
	self.event.keyMod = false 
	
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
	local font = require( "" .. name )
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
	rect.x, rect.y, rect.w, rect.h = 0, (charcode - 32) * 24, 14, 24
	rect2.x, rect2.y, rect2.w, rect2.h = x, y, 14, 24
	-- sdl.SDL_BlitSurface( self.font, rect, self.screen, rect2 )
	sdl.SDL_UpperBlit( self.font, rect, self.screen, rect2 )
end

function teaUI:drawString( s, x, y )
	for i=1, #s do
		self:drawCharCode( s:byte(i), x, y )
		x = x + 14
	end
end

function teaUI:drawRect( x, y, w, h, color )
	rect.x, rect.y, rect.w, rect.h = x, y, w, h
	sdl.SDL_FillRect( self.screen, rect, color )
end

function teaUI:regionHit( x, y, w, h )
	return ( self.event.mouseX >= x and
		self.event.mouseY >= y and
		self.event.mouseX <= x + w and
		self.event.mouseY <= y + h )
end

function teaUI:guiPrepare()
	self.hotItem = 0
end

function teaUI:guiFinish()
	if not self.event.mouseDown then
		self.activeItem = 0
	elseif self.activeItem == 0 then
		self.activeItem = -1
	end
	
	if self.event.keyEntered == SDLK_TAB then
		self.kbditem = 0
	end
	self.event.keyEntered = 0
end

function teaUI:render()
	local el = self.element
	self:drawRect( 0, 0, self.screenWidth, self.screenHeight, self.backgroundColor )
	
	self:guiPrepare()
	do
		for i=1, #el do
			local comp = el[ i ]
			comp:handleEvent( self.event )
		end
	end
	self:guiFinish()
	
	self:drawString( "0DDTest1238919283891289319823123", 10, 10 )
	
	sdl.SDL_UpdateRect( self.screen, 0, 0, self.screenWidth, self.screenHeight )
	self:sleep( 10 )
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
	local evt, key, mod = rawEvent.type, rawEvent.key.keysym.sym, rawEvent.key.keysym.mod
	local motion, button = rawEvent.motion, rawEvent.button.button
	--System
	if evt == sdl.SDL_QUIT then
		self.isShoudExit = true
	--Mouse
	elseif evt == sdl.SDL_MOUSEMOTION then
		self.event.mouseX, self.event.mouseY = motion.x, motion.y
	elseif evt == sdl.SDL_MOUSEBUTTONDOWN and button == 1 then
		self.event.mouseDown = true
	elseif evt == sdl.SDL_MOUSEBUTTONUP and button == 1 then
		self.event.mouseDown = false
	--KeyBoard
	elseif evt == sdl.SDL_KEYDOWN then
		self.event.keyEntered = key
		self.event.keyMod = mod
	elseif evt == sdl.SDL_KEYUP then
		if key == sdl.SDLK_ESCAPE then
			self.isShoudExit = true
		elseif key == sdl.SDLK_F1 then
			self.backgroundColor = bor( sdl.SDL_GetTicks() * 0xc0cac01a, 0x77 )
		end
	end
end

function teaUI:mainLoop()
	while not self.isShoudExit do
		while sdl.SDL_PollEvent( self.rawEvent ) ~= 0 do -- If non-rawEvent, then repaint only
			self:detectEvent( self.rawEvent ) -- Detect rawEvent
		end
		self:render() -- Render
	end
	
	sdl.SDL_Quit() -- Do Exit
end

function teaUI:start()
	self:init() -- Initialize
	self:mainLoop() -- Main Loop
end

return teaUI