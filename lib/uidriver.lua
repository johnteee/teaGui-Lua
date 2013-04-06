local Object = require ( "object" )
local ffi = require( "ffi" )
local sdl = require( "ffi/sdl" )
local Event = require( "event" )
local shiftLeft, shiftRight, bor, band, bxor, min, max, fmod = bit.lshift, bit.rshift, bit.bor, bit.band, bit.bxor, math.min, math.max, math.fmod

local uiDriver = Object:extend{
	className = "uiDriver",
	
	--Control
	event = nil,
	rawEvent = nil,
	
	--Layout
	width = 800, height = 600,
	nativeWidth = 0, nativeHeight = 0,
	fullScreen = false, nativeResolutionFullScreen = false,
	videoFlags = 0,
	
	fontWidth = 14, fontHeight = 24,
	fontRequire = "font14x24",
	
	--Platform
	platformConst = nil,
	eventTypeConst = nil
}

function uiDriver:init()
	--Env
	SDL_INIT_AUDIO = 0x00000010
	SDL_INIT_VIDEO = 0x00000020
	SDL_INIT_CDROM = 0x00000100
	SDL_INIT_JOYSTICK = 0x00000200
	SDL_INIT_NOPARACHUTE = 0x00100000
	SDL_INIT_EVENTTHREAD = 0x01000000
	SDL_INIT_EVERYTHING  = 0x0000FFFF
	
	sdl.SDL_Init( SDL_INIT_EVERYTHING )
	
	local displayMode = ffi.new( "SDL_DisplayMode" )
	sdl.SDL_GetDesktopDisplayMode( 0, displayMode )
	self.nativeWidth = displayMode.w
	self.nativeHeight = displayMode.h
	
	if self.fullScreen then
		if self.nativeResolutionFullScreen then
			self.width = self.nativeWidth
			self.height = self.nativeHeight
		end
		self.videoFlags = bor( self.videoFlags, sdl.SDL_FULLSCREEN )
	end
	
	self.videoFlags = bor( self.videoFlags, sdl.SDL_DOUBLEBUF )
	
	self.screen = sdl.SDL_SetVideoMode( self.width, self.height, 32, self.videoFlags )
	self.renderer = sdl.SDL_CreateSoftwareRenderer( self.screen )
	
	sdl.SDL_EnableKeyRepeat( sdl.SDL_DEFAULT_REPEAT_DELAY, sdl.SDL_DEFAULT_REPEAT_INTERVAL )
	sdl.SDL_EnableUNICODE(1)
	
	self.font = self:requireFont( self.fontRequire )
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
	
	--Platform
	self.platformConst = {}
	self.platformConst.KEYRETURN = sdl.SDLK_RETURN
	self.platformConst.KEYUP = sdl.SDLK_UP
	self.platformConst.KEYDOWN = sdl.SDLK_DOWN
	self.platformConst.BACKSPACE = sdl.SDLK_BACKSPACE
	self.platformConst.TAB = sdl.SDLK_TAB
	self.platformConst.ESCAPE = sdl.SDLK_ESCAPE
	self.platformConst.KEYMODESHIFT = sdl.KMOD_SHIFT
	
	self.eventTypeConst = {}
	self.eventTypeConst.QUIT = sdl.SDL_QUIT
	
	self.eventTypeConst.MOUSEMOTION = sdl.SDL_MOUSEMOTION
	self.eventTypeConst.MOUSEBUTTONDOWN = sdl.SDL_MOUSEBUTTONDOWN
	self.eventTypeConst.MOUSEBUTTONUP = sdl.SDL_MOUSEBUTTONUP
	self.eventTypeConst.PRESSED = sdl.SDL_PRESSED
	
	self.eventTypeConst.KEYDOWN = sdl.SDL_KEYDOWN
	self.eventTypeConst.KEYUP = sdl.SDL_KEYUP
end

function uiDriver:loadBitmap ( path )
	local file = sdl.SDL_RWFromFile( path, "rb")
	local temp = sdl.SDL_LoadBMP_RW(file, 1)
	local img = sdl.SDL_ConvertSurface( temp, self.screen.format, sdl.SDL_SWSURFACE )
	sdl.SDL_FreeSurface( temp )
	sdl.SDL_SetColorKey( img, sdl.SDL_SRCCOLORKEY, 0 )
	return img
end

function uiDriver:requireFont( name )
	local font = require( "font/" .. name )
	return self:makeFont( font )
end

function uiDriver:makeFont( font )
	local data = ffi.new( "uint8_t[?]", #font, font )
	local file = sdl.SDL_RWFromConstMem( data, ffi.sizeof(data) )
	local temp = sdl.SDL_LoadBMP_RW(file, 1)
	local font = sdl.SDL_ConvertSurface( temp, self.screen.format, sdl.SDL_SWSURFACE )
	sdl.SDL_FreeSurface( temp )
	sdl.SDL_SetColorKey( font, sdl.SDL_SRCCOLORKEY, 0 )
	return font
end

function uiDriver:drawCharCode( charcode, x, y )
	self.rectFg.x, self.rectFg.y, self.rectFg.w, self.rectFg.h = 0, (charcode - 32) * self.fontHeight, self.fontWidth, self.fontHeight
	self.rectBg.x, self.rectBg.y, self.rectBg.w, self.rectBg.h = x, y, self.fontWidth, self.fontHeight
	-- sdl.SDL_BlitSurface( self.font, self.rectFg, self.screen, self.rectBg )
	sdl.SDL_UpperBlit( self.font, self.rectFg, self.screen, self.rectBg )
end

function uiDriver:drawImage( img, x, y, width, height )
	self.rectFg.x, self.rectFg.y, self.rectFg.w, self.rectFg.h = 0, 0, width or img.w, height or img.h
	self.rectBg.x, self.rectBg.y, self.rectBg.w, self.rectBg.h = x, y, width or img.w, height or img.h
	-- sdl.SDL_BlitSurface( img, self.rectFg, self.screen, self.rectBg )
	sdl.SDL_UpperBlit( img, self.rectFg, self.screen, self.rectBg )
end

function uiDriver:drawRect( x, y, w, h, color )
	self.rectFg.x, self.rectFg.y, self.rectFg.w, self.rectFg.h = x, y, w, h
	
	r, g, b, alpha = self:getRGBA( color, alpha )
	sdl.SDL_SetRenderDrawColor( self.renderer, r, g, b, alpha)
	sdl.SDL_RenderFillRect( self.renderer, self.rectFg )
end

function uiDriver:drawRectWire( x, y, w, h, color, alpha)
	self.rectFg.x, self.rectFg.y, self.rectFg.w, self.rectFg.h = x, y, w, h
	
	r, g, b, alpha = self:getRGBA( color, alpha )
	sdl.SDL_SetRenderDrawColor( self.renderer, r, g, b, alpha)
	sdl.SDL_RenderDrawRect( self.renderer, self.rectFg )
end

function uiDriver:getRGBA( color, alpha )
	local r, g, b =
	shiftRight( color, 8 + 8 ), shiftRight( fmod( color, (256 * 256) ) , 8 ),
	fmod( color, (256) )
	alpha = alpha or 0.1

	return r, g, b, alpha
end

function uiDriver:refresh()
	sdl.SDL_UpdateRect( self.screen, 0, 0, self.width, self.width )
end

function uiDriver:setWindowTitle( title )
	sdl.SDL_WM_SetCaption( title, nil );
end

function uiDriver:randomColor()
	return bor( sdl.SDL_GetTicks() * 0xc0cac01a, 0x77 )
end

function uiDriver:toggleFullScreen()
	-- if self.nativeResolutionFullScreen then
		-- self.videoFlags = bxor( self.videoFlags, sdl.SDL_FULLSCREEN )
		-- local oldscreen, oldrenderer = self.screen, self.renderer
		-- self.screen = sdl.SDL_SetVideoMode( self.width, self.height, 32, self.videoFlags )
		-- self.renderer = sdl.SDL_CreateSoftwareRenderer( self.screen )
		-- -- sdl.SDL_FreeSurface( oldscreen )
		-- -- sdl.SDL_Free( oldrenderer )
	-- else
		sdl.SDL_WM_ToggleFullScreen( self.screen )
	-- end
end

function uiDriver:isShowCursorNow()
	return band(shiftRight(sdl.SDL_GetTicks(), 8), 1)
end

function uiDriver:sleep( msec )
	sdl.SDL_Delay( msec )
end

function uiDriver:getEvent()
	return self.event
end

function uiDriver:handleRawEvent( rawEvent )
	local evttype, key, keymod, keyunicode = rawEvent.type, rawEvent.key.keysym.sym, rawEvent.key.keysym.mod, rawEvent.key.keysym.unicode
	local buttonbutton, buttonmousestate = rawEvent.button.button, rawEvent.button.state
	local motionmousestate = rawEvent.motion.state
	local buttonx, buttony, motionx, motiony = rawEvent.button.x, rawEvent.button.y, rawEvent.motion.x, rawEvent.motion.y
	local evt = self:getEvent()
	local eventTypeConst = self.eventTypeConst
	
	evt.eventType = evttype
	
	--Mouse
	if self:isEventType( evt, eventTypeConst.MOUSEMOTION ) then
		evt.mouseDown = motionmousestate == eventTypeConst.PRESSED
		evt.mouseX, evt.mouseY = motionx, motiony
	elseif self:isEventType( evt, eventTypeConst.MOUSEBUTTONDOWN ) then
		evt.mouseDown = buttonmousestate == eventTypeConst.PRESSED
		evt.mouseButton = buttonbutton
		evt.mouseX, evt.mouseY = buttonx, buttony
	elseif self:isEventType( evt, eventTypeConst.MOUSEBUTTONUP ) then
		evt.mouseDown = buttonmousestate == eventTypeConst.PRESSED
		evt.mouseButton = buttonbutton
		evt.mouseX, evt.mouseY = buttonx, buttony
	--KeyBoard
	elseif self:isEventType( evt, eventTypeConst.KEYDOWN ) then
		evt.keyEntered = key
		evt.keyMod = keymod
		if band(keyunicode, 0xFF80) == 0 then
			evt.keyChar = band(keyunicode, 0x7F);
		end
	elseif self:isEventType( evt, eventTypeConst.KEYUP ) then
		
	end
	
	self.event = evt
	
	return evt
end

function uiDriver:isKeyMod( evt, keyMod )
	return band( evt.keyMod, keyMod )
end

function uiDriver:isKeyEntered( evt, key )
	return evt.keyEntered == key
end

function uiDriver:isEventType( evt, eventType )
	return evt.eventType == eventType
end

function uiDriver:isAnyEvent()
	if sdl.SDL_PollEvent( self.rawEvent ) ~= 0 then
		return true
	else
		return false
	end
end

function uiDriver:quit ()
	sdl.SDL_Quit()
end

return uiDriver