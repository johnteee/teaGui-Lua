local sdl = require( "ffi/sdl" )
local Component = require( "component" )

local Image = Component:new{
	width = 64, height = 48,
	img = nil, canFocusOn = false
}

function Image:create ( ID, x, y, img, width, height )
	local newOne = self:new()
	newOne.ID = ID or newOne.ID
	newOne.x = x or newOne.x
	newOne.y = y or newOne.y
	newOne.img = img or newOne.img
	newOne.width = width or img.w or newOne.width
	newOne.height = height or img.h or newOne.height
	return newOne
end

function Image:handleEvent ( evt )
	local eventType = self:detectEvent( evt )
	
	if( eventType ~= "nothing") then
		self.parent:focusOn( self )
	end
	
	if( eventType == "click") then
		self:onClick ( evt )
	end
end

function Image:detectEvent ( evt )
	local xspace, yspace = 8, 8
	
	self.parent:checkHitOn( self, self.x - xspace/2, self.y - yspace/2, self.width, self.height )
	
	if self.parent:isFocusOn( self ) then
		self.parent:drawRect( self.x-xspace*3/4, self.y-yspace*3/4, self.width + (xspace*4/4), self.height + (yspace*4/4), 0xff0000 )
	end
	
	self.parent:drawImage( self.img, self.x, self.y, self.width, self.height )
	
	self.parent:checkSwitchFocus( self )
	
	local triggerClick = ( not evt.mouseDown
		and self.parent:isMouseHover( self )
		and self.parent:isMousePress( self ) )
	
	if self.parent:isFocusOn( self ) then
		if evt.keyEntered == sdl.SDLK_RETURN then
			triggerClick = true
		end
	end
	
	if( triggerClick ) then
		return "click"
	else
		return "nothing"
	end
end

function Image:changeBuffer( str )
	self.buffer = str
end

function Image:onClick ( evt )
end

return Image