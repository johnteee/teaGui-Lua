local ffi = require( "ffi" )
local sdl = require( "ffi/sdl" )
local Object = require( "object" )
local Component = require( "component" )

local shiftLeft, shiftRight, bor, band, min, max = bit.lshift, bit.rshift, bit.bor, bit.band, math.min, math.max

local Slider = Component:new{
	maxValue = 100, value = 50,
	width = 16, height = 255
}

function Slider:create ( ID, x, y, width, height, maxValue, value )
	local newOne = self:new()
	newOne.ID = ID or newOne.ID
	newOne.x = x or newOne.x
	newOne.y = y or newOne.y
	newOne.width = width or newOne.width
	newOne.height = height or newOne.height
	newOne.maxValue = maxValue or newOne.maxValue
	newOne.value = value or newOne.value
	return newOne
end

function Slider:handleEvent ( evt )
	local eventType, value = self:detectEvent( evt )
	if( eventType == "change") then
		self.value = value
		self:onChange ()
	end
end

function Slider:detectEvent ( evt )
	local xspace, yspace = 8, (self.height/16)/2
	local ypos = (self.height + 1 - 16) * self.value / self.maxValue
	
	if self.parent:regionHit( self.x+8, self.y+8, self.width, self.height ) then
		self.parent.hotItem = self.ID
		if self.parent.activeItem == 0 and evt.mouseDown then
			self.parent.activeItem = self.ID
		end
	end

	if self.parent.kbdItem == 0 then
		self.parent.kbdItem = self.ID;
	end

	if self.parent.kbdItem == self.ID then
		self.parent:drawRect( self.x-4, self.y-4, self.width + 24, self.height + 25, 0xff0000 )
	end
	
	self.parent:drawRect( self.x,self.y, self.width+xspace*2, self.height+yspace*2, 0x777777 )
	
	if self.parent.activeItem == self.ID or self.parent.hotItem == self.ID then
		self.parent:drawRect( self.x+8, self.y+8 + ypos, self.width, yspace*2, 0xffffff )
	else
		self.parent:drawRect( self.x+8, self.y+8 + ypos, self.width, yspace*2, 0xaaaaaa )
	end
	
	if self.parent.kbdItem == self.ID then
		if evt.keyEntered == sdl.SDLK_TAB then
			self.parent.kbdItem = 0
			if band( evt.keyMod, sdl.KMOD_SHIFT ) then
				self.parent.kbdItem = self.parent.lastWidget;
			end
			evt.keyEntered = 0;
		elseif evt.keyEntered == sdl.SDLK_UP then
			if self.value > 0 then
				self.value = self.value - 1
				return "change", self.value
			end
		elseif evt.keyEntered == sdl.SDLK_DOWN then
			if self.value < self.maxValue then
				self.value = self.value + 1
				return "change", self.value
			end
		end
	end
	
	self.parent.lastWidget = self.ID
	
	if self.parent.activeItem == self.ID then
		local mousePosition = evt.mouseY - ( self.y + 8 )
		mousePosition = max( mousePosition, 0 )
		mousePosition = min( mousePosition, self.height )
		local v = mousePosition * self.maxValue / self.height
		if v ~= self.value then
			return "change", v
		end
	end
	
	return "nothing", self.value
end

function Slider:onChange ()
end

return Slider