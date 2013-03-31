local ffi = require( "ffi" )
local sdl = require( "ffi/sdl" )
local Object = require( "object" )
local Component = require( "component" )

local shiftLeft, shiftRight, bor, band, min, max = bit.lshift, bit.rshift, bit.bor, bit.band, math.min, math.max

local Button = Component:new{
	width = 64, height = 48
}

function Button:create ( ID, x, y, width, height )
	local newOne = self:new()
	newOne.ID = ID or newOne.ID
	newOne.x = x or newOne.x
	newOne.y = y or newOne.y
	newOne.width = width or newOne.width
	newOne.height = height or newOne.height
	return newOne
end

function Button:handleEvent ( evt )
	local eventType = self:detectEvent( evt )
	if( eventType == "click") then
		self:onClick ()
	end
end

function Button:detectEvent ( evt )
	if self.parent:regionHit( self.x, self.y, 64, 48 ) then
		self.parent.hotItem = self.ID
		if self.parent.activeItem == 0 and evt.mouseDown then
			self.parent.activeItem = self.ID
		end
	end
	
	if self.parent.kbdItem == 0 then
		self.parent.kbdItem = self.ID
	end
	
	if self.parent.kbdItem == self.ID then
		self.parent:drawRect( self.x - 6, self.y - 6, self.width + 20, self.height + 20, 0xff0000 )
	end
	
	self.parent:drawRect( self.x + 8, self.y + 8, self.width, self.height, 0 )
	
	if self.parent.hotItem == self.ID then
		if self.parent.activeItem == self.ID then
			self.parent:drawRect( self.x + 2, self.y + 2, self.width, self.height, 0xffffff )
		else
			self.parent:drawRect( self.x, self.y, self.width, self.height, 0xffffff )
		end
	else
		self.parent:drawRect( self.x, self.y, self.width, self.height, 0xaaaaaa )
	end
	
	if self.parent.kbdItem == self.ID then
		if evt.keyEntered == sdl.SDLK_TAB then
			self.parent.kbdItem = 0
			if band( evt.keyMod, sdl.KMOD_SHIFT ) then
				self.parent.kbdItem = self.parent.lastWidget
			end
			evt.keyEntered = 0
		elseif evt.keyEntered == sdl.SDLK_RETURN then
			return "click"
		end
	end
	
	self.parent.lastWidget = self.ID;
	
	local triggerClick = ( not evt.mouseDown
		and self.parent.hotItem == self.ID
		and self.parent.activeItem == self.ID )
	
	if( triggerClick ) then
		return "click"
	end
	
	return "nothing"
end

function Button:onClick ()
end

return Button