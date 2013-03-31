local sdl = require( "ffi/sdl" )
local Component = require( "component" )

local Button = Component:new{
	width = 64, height = 48,
	xfloat = 20, yfloat = 20
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
	
	if( eventType ~= "nothing") then
		self.parent:focusOn( self )
	end
	
	if( eventType == "click") then
		self:onClick ( evt )
	end
end

function Button:detectEvent ( evt )
	self.parent:checkHitOn( self, self.x, self.y, self.width, self.height )
	
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

function Button:paint ()
	local shadowRate = 0.15
	
	if self.parent:isMouseHover( self ) then
		if self.parent:isMousePress( self ) then
			if self.parent:isFocusOn( self ) then
				self.parent:drawRect( self.x - self.xspace + self.xfloat*(1 + shadowRate/2), self.y - self.yspace + self.yfloat*(1 + shadowRate/2), self.width + self.xspace*3 + self.xfloat*shadowRate, self.height + self.yspace*3 + self.yfloat*shadowRate, 0xff0000 )
			end
			self.parent:drawRect( self.x + self.xspace + self.xfloat*(1 + shadowRate/2), self.y + self.yspace + self.yfloat*(1 + shadowRate/2), self.width, self.height, 0 )
			self.parent:drawRect( self.x + self.xfloat*(1 + shadowRate/2), self.y + self.yfloat*(1 + shadowRate/2), self.width, self.height, 0xffffff )
		else
			if self.parent:isFocusOn( self ) then
				self.parent:drawRect( self.x - self.xspace + self.xfloat*(1 + shadowRate/2), self.y - self.yspace + self.yfloat*(1 + shadowRate/2), self.width + self.xspace*3 + self.xfloat*shadowRate, self.height + self.yspace*3 + self.yfloat*shadowRate, 0xff0000 )
			end
			self.parent:drawRect( self.x + self.xfloat*(1 + shadowRate/2), self.y + self.yfloat*(1 + shadowRate/2), self.width + self.xspace + self.xfloat*shadowRate, self.height + self.yspace + self.yfloat*shadowRate, 0 )
			self.parent:drawRect( self.x, self.y, self.width, self.height, 0xffffff )
		end
	else
		if self.parent:isFocusOn( self ) then
			self.parent:drawRect( self.x - self.xspace + self.xfloat*(1 + shadowRate/2), self.y - self.yspace + self.yfloat*(1 + shadowRate/2), self.width + self.xspace*3 + self.xfloat*shadowRate, self.height + self.yspace*3 + self.yfloat*shadowRate, 0xff0000 )
		end
		self.parent:drawRect( self.x + self.xfloat*(1 + shadowRate/2), self.y + self.yfloat*(1 + shadowRate/2), self.width + self.xspace + self.xfloat*shadowRate, self.height + self.yspace + self.yfloat*shadowRate, 0 )
		self.parent:drawRect( self.x, self.y, self.width, self.height, 0xaaaaaa )
	end
end

function Button:onClick ( evt )
end

return Button