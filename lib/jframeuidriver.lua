package.path = package.path .. ";../?.lua;?.lua;lib/?.lua"

local Object = require ( "lib.object" )
local Event = require( "lib.event" )

if luajava ~= nil then
	bit = luajava.newInstance( "org.luaj.vm2.lib.Bit32Lib" )
end

local shiftLeft, shiftRight, bor, band, bxor, min, max, fmod = bit.lshift, bit.rshift, bit.bor, bit.band, bit.bxor, math.min, math.max, math.fmod

local jframeUIDriver = Object:extend{
	className = "jframeUIDriver",
	
	--Control
	event = nil,
	rawEvent = nil,
	
	--Layout
	width = 800, height = 600,
	nativeWidth = 0, nativeHeight = 0,
	fullScreen = false, nativeResolutionFullScreen = false,
	videoFlags = 0,cursorSpeed = 500,
	
	fontWidth = 14, fontHeight = 24,
	fontRequire = "font14x24",
	
	--Platform
	platformConst = nil,
	eventTypeConst = nil
}

function jframeUIDriver:init()
	--Env
	local borderLayout = luajava.bindClass("java.awt.BorderLayout")
	local jframe = luajava.bindClass("javax.swing.JFrame")
	local bufferedImage = luajava.bindClass("java.awt.image.BufferedImage")
	local swingUtilities = luajava.bindClass("javax.swing.SwingUtilities")
	local thread = luajava.bindClass("java.lang.Thread")

	-- set up frame, get content pane
	local frame = luajava.newInstance("javax.swing.JFrame", "Sample Luaj Application");
	frame:setResizable ( false )
	local content = frame:getContentPane()

	-- add a buffered image as content
	local image = luajava.newInstance("java.awt.image.BufferedImage", 640, 480, bufferedImage.TYPE_INT_RGB)
	local icon = luajava.newInstance("javax.swing.ImageIcon", image)
	local label = luajava.newInstance("javax.swing.JLabel", icon)

	-- add the main pane to the main content
	content:add(label, borderLayout.CENTER)
	frame:setDefaultCloseOperation(jframe.EXIT_ON_CLOSE)
	frame:pack()
	
	frame:setVisible( true )
	
	--Init Display
	--Record desktop screen width and height
	--FullScreen or Window Mode
	--Setup Rendering
	--Setup Key Event And Unicode
	--Load Font
	
	--Control
	self.event = Event:new()
	local evt = self:getEvent()
	evt.mouseDown = false
	evt.mouseX = 0
	evt.mouseY = 0
	evt.keyEntered = 0
	evt.keyChar = 0
	evt.keyMod = false 
	
	-- --Platform
	-- --Define PlatformConst
	-- self.platformConst = {}
	-- self.platformConst.KEYRETURN = sdl.SDLK_RETURN
	-- self.platformConst.KEYUP = sdl.SDLK_UP
	-- self.platformConst.KEYDOWN = sdl.SDLK_DOWN
	-- self.platformConst.BACKSPACE = sdl.SDLK_BACKSPACE
	-- self.platformConst.TAB = sdl.SDLK_TAB
	-- self.platformConst.ESCAPE = sdl.SDLK_ESCAPE
	-- self.platformConst.KEYMODESHIFT = sdl.KMOD_SHIFT
	
	-- --Define EventTypeConst
	-- self.eventTypeConst = {}
	-- self.eventTypeConst.QUIT = sdl.SDL_QUIT
	
	-- self.eventTypeConst.MOUSEMOTION = sdl.SDL_MOUSEMOTION
	-- self.eventTypeConst.MOUSEBUTTONDOWN = sdl.SDL_MOUSEBUTTONDOWN
	-- self.eventTypeConst.MOUSEBUTTONUP = sdl.SDL_MOUSEBUTTONUP
	-- self.eventTypeConst.PRESSED = sdl.SDL_PRESSED
	
	-- self.eventTypeConst.KEYDOWN = sdl.SDL_KEYDOWN
	-- self.eventTypeConst.KEYUP = sdl.SDL_KEYUP
end

function jframeUIDriver:loadBitmap ( path )
	return img
end

function jframeUIDriver:requireFont( name )
	local font = require( "font/" .. name )
	return self:makeFont( font )
end

function jframeUIDriver:makeFont( font )
	return font
end

function jframeUIDriver:drawCharCode( charcode, x, y )
end

function jframeUIDriver:drawImage( img, x, y, width, height )
end

function jframeUIDriver:drawRect( x, y, w, h, color )
end

function jframeUIDriver:drawRectWire( x, y, w, h, color, alpha)
end

function jframeUIDriver:getRGBA( color, alpha )
	local r, g, b =
	shiftRight( color, 8 + 8 ), shiftRight( fmod( color, (256 * 256) ) , 8 ),
	fmod( color, (256) )
	alpha = alpha or 0.1

	return r, g, b, alpha
end

function jframeUIDriver:refresh()
end

function jframeUIDriver:setWindowTitle( title )
end

function jframeUIDriver:randomColor()
	return bor( self:getTimestamp() * 0xc0cac01a, 0x77 )
end

function jframeUIDriver:toggleFullScreen()
	-- if self.nativeResolutionFullScreen then
		-- self.videoFlags = bxor( self.videoFlags, sdl.SDL_FULLSCREEN )
		-- local oldscreen, oldrenderer = self.screen, self.renderer
		-- self.screen = sdl.SDL_SetVideoMode( self.width, self.height, 32, self.videoFlags )
		-- self.renderer = sdl.SDL_CreateSoftwareRenderer( self.screen )
		-- -- sdl.SDL_FreeSurface( oldscreen )
		-- -- sdl.SDL_Free( oldrenderer )
	-- else
		-- sdl.SDL_WM_ToggleFullScreen( self.screen )
	-- end
end

function jframeUIDriver:isShowCursorNow()
	local speed = self.cursorSpeed
	return fmod(self:getTimestamp(), speed) < speed/2--band(shiftRight(self:getTimestamp(), 8), 1)
end

function jframeUIDriver:getTimestamp()
	return os.clock() * 1000
end

function jframeUIDriver:sleep( msec )
end

function jframeUIDriver:getEvent()
	return self.event
end

function jframeUIDriver:handleRawEvent( rawEvent )
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

function jframeUIDriver:isKeyMod( evt, keyMod )
	return band( evt.keyMod, keyMod )
end

function jframeUIDriver:isKeyEntered( evt, key )
	return evt.keyEntered == key
end

function jframeUIDriver:isEventType( evt, eventType )
	return evt.eventType == eventType
end

function jframeUIDriver:isAnyEvent()
end

function jframeUIDriver:quit ()
end

return jframeUIDriver