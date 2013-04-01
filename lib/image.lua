local sdl = require( "ffi/sdl" )
local Component = require( "component" )

local Image = Component:extend{
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
	self:super().handleEvent ( self, evt )
end

function Image:detectEvent ( evt )
	self.hitRegion.x, self.hitRegion.y, self.hitRegion.width, self.hitRegion.height =
	self.x - self.xspace/2, self.y - self.yspace/2, self.width, self.height
	
	return self:super().detectEvent( self, evt )
end

function Image:paint ()
	if self.parent:isFocusOn( self ) then
		self.parent:drawRect( self.x-self.xspace*3/4, self.y-self.yspace*3/4, self.width + (self.xspace*4/4), self.height + (self.yspace*4/4), 0xff0000 )
	end
	
	self.parent:drawImage( self.img, self.x, self.y, self.width, self.height )
end

return Image