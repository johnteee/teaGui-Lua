local ffi = require( "ffi" )
local sdl = require( "ffi/sdl" )
local Component = require( "component" )

local min, max = math.min, math.max

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
	
	if( eventType ~= "nothing") then
		self.parent:focusOn( self.ID )
	end
	
	if( eventType == "change") then
		self.value = value
		self:onChange ( evt )
	end
end

function Slider:detectEvent ( evt )
	local xspace, yspace, yvarspace = 8, 8, (self.height/16)/2
	local ypos = (self.height + 1 - yspace*2) * self.value / self.maxValue
	
	self.parent:checkHitOn( self.ID, self.x+xspace, self.y+yspace, self.width, self.height )
	
	if self.parent:isFocusOn( self.ID ) then
		self.parent:drawRect( self.x-xspace/2, self.y-yspace/2, self.width + xspace*3, self.height + yvarspace*2+yspace+1, 0xff0000 )
	end
	
	self.parent:drawRect( self.x,self.y, self.width+xspace*2, self.height+yvarspace*2, 0x777777 )
	
	if self.parent:isMouseHover( self.ID ) then
		if self.parent:isMousePress( self.ID ) then
			self.parent:drawRect( self.x+xspace, self.y+yspace + ypos, self.width, yvarspace*2, 0x444444 )
		else
			self.parent:drawRect( self.x+xspace, self.y+yspace + ypos, self.width, yvarspace*2, 0xffffff )
		end
	else
		self.parent:drawRect( self.x+xspace, self.y+yspace + ypos, self.width, yvarspace*2, 0xaaaaaa )
	end
	
	self.parent:checkSwitchFocus( self.ID )
	
	local triggerChange = false
	if self.parent:isFocusOn( self.ID ) then
		if evt.keyEntered == sdl.SDLK_UP then
			if self.value > 0 then
				self.value = self.value - 1
				triggerChange = true
			end
		elseif evt.keyEntered == sdl.SDLK_DOWN then
			if self.value < self.maxValue then
				self.value = self.value + 1
				triggerChange = true
			end
		end
	end
	
	if self.parent:isMousePress( self.ID ) then
		local mousePosition = evt.mouseY - ( self.y + yspace )
		mousePosition = max( mousePosition, 0 )
		mousePosition = min( mousePosition, self.height )
		local v = mousePosition * self.maxValue / self.height
		if v ~= self.value then
			self.value = v
			triggerChange = true
		end
	end
	
	if triggerChange == true then
		return "change", self.value
	else
		return "nothing", self.value
	end
end

function Slider:onChange ( evt )
end

return Slider