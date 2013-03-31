local sdl = require( "ffi/sdl" )
local Component = require( "component" )

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
	
	if( eventType ~= "nothing") then
		self.parent:focusOn( self )
	end
	
	if( eventType == "click") then
		self:onClick ( evt )
	end
end

function Button:detectEvent ( evt )
	local xspace, yspace, xfloat, yfloat, shadowRate = 8, 8, 20, 20, 0.15
	
	self.parent:checkHitOn( self, self.x, self.y, self.width, self.height )
	
	if self.parent:isMouseHover( self ) then
		if self.parent:isMousePress( self ) then
			if self.parent:isFocusOn( self ) then
				self.parent:drawRect( self.x - xspace + xfloat*(1 + shadowRate/2), self.y - yspace + yfloat*(1 + shadowRate/2), self.width + xspace*3 + xfloat*shadowRate, self.height + yspace*3 + yfloat*shadowRate, 0xff0000 )
			end
			self.parent:drawRect( self.x + xspace + xfloat*(1 + shadowRate/2), self.y + yspace + yfloat*(1 + shadowRate/2), self.width, self.height, 0 )
			self.parent:drawRect( self.x + xfloat*(1 + shadowRate/2), self.y + yfloat*(1 + shadowRate/2), self.width, self.height, 0xffffff )
		else
			if self.parent:isFocusOn( self ) then
				self.parent:drawRect( self.x - xspace + xfloat*(1 + shadowRate/2), self.y - yspace + yfloat*(1 + shadowRate/2), self.width + xspace*3 + xfloat*shadowRate, self.height + yspace*3 + yfloat*shadowRate, 0xff0000 )
			end
			self.parent:drawRect( self.x + xfloat*(1 + shadowRate/2), self.y + yfloat*(1 + shadowRate/2), self.width + xspace + xfloat*shadowRate, self.height + yspace + yfloat*shadowRate, 0 )
			self.parent:drawRect( self.x, self.y, self.width, self.height, 0xffffff )
		end
	else
		if self.parent:isFocusOn( self ) then
			self.parent:drawRect( self.x - xspace + xfloat*(1 + shadowRate/2), self.y - yspace + yfloat*(1 + shadowRate/2), self.width + xspace*3 + xfloat*shadowRate, self.height + yspace*3 + yfloat*shadowRate, 0xff0000 )
		end
		self.parent:drawRect( self.x + xfloat*(1 + shadowRate/2), self.y + yfloat*(1 + shadowRate/2), self.width + xspace + xfloat*shadowRate, self.height + yspace + yfloat*shadowRate, 0 )
		self.parent:drawRect( self.x, self.y, self.width, self.height, 0xaaaaaa )
	end
	
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

function Button:onClick ( evt )
end

return Button