local Component = require( "component" )

local Button = Component:extend{
	className = "Button",
	
	width = 64, height = 48,
	xfloat = 2, yfloat = 2
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
	self:super().handleEvent ( self, evt )
end

function Button:detectEvent ( evt )
	self:setHitRegion( self.x, self.y, self.width, self.height )
	
	return self:super().detectEvent( self, evt )
end

function Button:paint ()
	--self:super().paint( self )
	
	local shadowRate = 0.15
	
	if self.parent:isMouseHover( self ) then
		if self.parent:isMousePress( self ) then
			if self.parent:isFocusOn( self ) then
				self.parent:drawRectWire( self.x - self.xspace + self.xfloat*(1 + shadowRate/2), self.y - self.yspace + self.yfloat*(1 + shadowRate/2), self.width + self.xspace*3 + self.xfloat*shadowRate, self.height + self.yspace*3 + self.yfloat*shadowRate, 0xff0000 )
			end
			self.parent:drawRect( self.x + self.xspace + self.xfloat*(1 + shadowRate/2), self.y + self.yspace + self.yfloat*(1 + shadowRate/2), self.width, self.height, 0 )
			self.parent:drawRect( self.x + self.xfloat*(1 + shadowRate/2), self.y + self.yfloat*(1 + shadowRate/2), self.width, self.height, 0xffffff )
		else
			if self.parent:isFocusOn( self ) then
				self.parent:drawRectWire( self.x - self.xspace + self.xfloat*(1 + shadowRate/2), self.y - self.yspace + self.yfloat*(1 + shadowRate/2), self.width + self.xspace*3 + self.xfloat*shadowRate, self.height + self.yspace*3 + self.yfloat*shadowRate, 0xff0000 )
			end
			self.parent:drawRect( self.x + self.xfloat*(1 + shadowRate/2), self.y + self.yfloat*(1 + shadowRate/2), self.width + self.xspace + self.xfloat*shadowRate, self.height + self.yspace + self.yfloat*shadowRate, 0 )
			self.parent:drawRect( self.x, self.y, self.width, self.height, 0xffffff )
		end
	else
		if self.parent:isFocusOn( self ) then
			self.parent:drawRectWire( self.x - self.xspace + self.xfloat*(1 + shadowRate/2), self.y - self.yspace + self.yfloat*(1 + shadowRate/2), self.width + self.xspace*3 + self.xfloat*shadowRate, self.height + self.yspace*3 + self.yfloat*shadowRate, 0xff0000 )
		end
		self.parent:drawRect( self.x + self.xfloat*(1 + shadowRate/2), self.y + self.yfloat*(1 + shadowRate/2), self.width + self.xspace + self.xfloat*shadowRate, self.height + self.yspace + self.yfloat*shadowRate, 0 )
		self.parent:drawRect( self.x, self.y, self.width, self.height, 0xaaaaaa )
	end
end

function Button:onKeyDown( evt )
	if self.parent:isKeyEntered( evt, self.parent:getPlatformConst().KEYRETURN ) then
			self:onClick( evt )
	end
end

return Button