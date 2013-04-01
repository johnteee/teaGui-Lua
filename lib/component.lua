local Object = require( "object" )

local Component = Object:extend{
	x = 0, y = 0,
	width = 0, height = 0,
	hitRegion = nil,
	outRegion = nil,
	
	xspace = 8, yspace = 8,
	
	ID = 0,
	parent = nil,
	canFocusOn = true,
	canEventOn = true
}

function Component:new ( obj )
	obj = Object.new( self, obj )
	obj.hitRegion = {}
	obj.outRegion = {}
	return obj
end

function Component:handleEvent ( evt )
	local eventType = self:detectEvent( evt )
	
	if( eventType ~= "nothing") then
		self.parent:focusOn( self )
	end
	
	if( eventType == "mousedown") then
		self:onMouseDown ( evt )
		return
	elseif( eventType == "click") then
		self:onClick ( evt )
		return
	end
end

function Component:detectEvent ( evt )
	self:setOutRegion( self.hitRegion.x, self.hitRegion.y, self.hitRegion.width, self.hitRegion.height )
	
	self.parent:checkHitOn( self, self.hitRegion.x, self.hitRegion.y, self.hitRegion.width, self.hitRegion.height )
	
	self.parent:checkSwitchFocus( self )
	
	local triggerClick = ( not evt.mouseDown
		and self.parent:isMouseHover( self )
		and self.parent:isMousePress( self ) )
	
	if self.parent:isFocusOn( self ) then
		if evt.keyEntered == self.parent.platformConst.KEYRETURN then
			triggerClick = true
		end
	end
	
	if( triggerClick ) then
		return "click"
	end
	
	local triggerMouseDown = self.parent:isMousePress( self ) and evt.mouseDown
	if triggerMouseDown then
		return "mousedown"
	end
	
	return "nothing"
end

function Component:paint ()
	if self.parent:isFocusOn( self ) and self.canFocusOn then
		self.parent:drawRectWire( self.outRegion.x, self.outRegion.y, self.outRegion.width, self.outRegion.height, 0xff0000 )
	end
end

function Component:onMouseUp ( evt )
end

function Component:onMouseDown ( evt )
end

function Component:onClick ( evt )
end

function Component:setHitRegion( x, y, w, h )
	self.hitRegion.x, self.hitRegion.y, self.hitRegion.width, self.hitRegion.height =
		x, y, w, h
end

function Component:setOutRegion( x, y, w, h )
	self.outRegion.x, self.outRegion.y, self.outRegion.width, self.outRegion.height =
		x, y, w, h
end



return Component