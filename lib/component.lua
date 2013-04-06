local Object = require( "object" )

local Component = Object:extend{
	className = "Component",
	
	x = 0, y = 0,
	width = 0, height = 0,
	hitRegion = nil,
	outRegion = nil,
	
	xspace = 8, yspace = 8,
	
	ID = 0,
	parent = nil,
	canFocusOn = true,
	canEventOn = true,
	canHoverOn = true,
	canPressFocus = true,
	canHoverFocus = true,
	canDrag = true
}

function Component:new ( obj )
	obj = Object.new( self, obj )
	obj.hitRegion = {}
	obj.outRegion = {}
	return obj
end

function Component:handleEvent ( evt )
	if self.canEventOn == false then
		return
	end
	
	local eventArray, valueArray = self:detectEvent( evt )
	
	for key in pairs(eventArray) do
		if ( key == "mousedown" or key == "click" ) and self.canPressFocus then
			self.parent:focusOn( self )
		end
		
		local theFunc = nil
		
		if( key == "mousedown") then
			theFunc = self.onMouseDown
		elseif( key == "mouseup") then
			theFunc = self.onMouseUp
		elseif( key == "mousemotion") then
			theFunc = self.onMouseMotion
		elseif( key == "click") then
			theFunc = self.onClick
		elseif( key == "drag") then
			theFunc = self.onDrag
		elseif( key == "keydown") then
			theFunc = self.onKeyDown
		elseif( key == "keyup") then
			theFunc = self.onKeyUp
		end
		
		if theFunc ~= nil then
			self.parent:createEventThreadAndStart( theFunc, self, evt )
		end
	end
	
	return eventArray, valueArray
end

function Component:detectEvent ( evt )
	local eventArray, valueArray = {}, {}
	eventArray.empty = true
	
	self:setOutRegion( self.hitRegion.x, self.hitRegion.y, self.hitRegion.width, self.hitRegion.height )
	
	self.parent:checkHitOn( self, self.hitRegion.x, self.hitRegion.y, self.hitRegion.width, self.hitRegion.height )
	
	self.parent:checkSwitchFocus( self )
	
	local triggerClick = ( not evt.mouseDown
		and self.parent:isMouseHover( self )
		and self.parent:isMousePress( self ) )
	
	if( triggerClick ) then
		eventArray["click"] = "click"
		valueArray["click"] = "click"
		eventArray.empty = false
	end
	
	local triggerMouseDown = self.parent:isMouseHover( self ) and evt.mouseDown and self.parent:isEventType ( evt, self.parent:getEventTypeConst().MOUSEBUTTONDOWN )
	if triggerMouseDown then
		eventArray["mousedown"] = "mousedown"
		valueArray["mousedown"] = "mousedown"
		eventArray.empty = false
	end
	
	local triggerMouseUp = self.parent:isMouseHover( self ) and not evt.mouseDown and self.parent:isEventType ( evt, self.parent:getEventTypeConst().MOUSEBUTTONUP )
	if triggerMouseUp then
		eventArray["mouseup"] = "mouseup"
		valueArray["mouseup"] = "mouseup"
		eventArray.empty = false
	end
	
	local triggerDrag = self.parent:isMousePress( self ) and self.canDrag and evt.mouseDown and self.parent:isEventType ( evt, self.parent:getEventTypeConst().MOUSEMOTION )
	if triggerDrag then
		eventArray["drag"] = "drag"
		valueArray["drag"] = "drag"
		eventArray.empty = false
	end
	
	local triggerMouseMotion = (self.parent:isMouseHover( self ) or self.parent:isMousePress( self )) and self.parent:isEventType ( evt, self.parent:getEventTypeConst().MOUSEMOTION )
	if triggerMouseMotion then
		eventArray["mousemotion"] =  "mousemotion"
		valueArray["mousemotion"] =  "mousemotion"
		eventArray.empty = false
	end
	
	local triggerKeyDown = self.parent:isFocusOn( self ) and self.parent:isEventType ( evt, self.parent:getEventTypeConst().KEYDOWN )
	if triggerKeyDown then
		eventArray["keydown"] =  "keydown"
		valueArray["keydown"] =  "keydown"
		eventArray.empty = false
	end
	
	local triggerKeyUp = self.parent:isFocusOn( self ) and self.parent:isEventType ( evt, self.parent:getEventTypeConst().KEYUP )
	if triggerKeyUp then
		eventArray["keyup"] =  "keyup"
		valueArray["keyup"] =  "keyup"
		eventArray.empty = false
	end
	
	if( eventArray.empty == false ) then
		return eventArray, valueArray
	end
	
	return { ["nothing"] = "nothing" }, { ["nothing"] = "nothing" }
end

function Component:paint ()
	if self.parent:isFocusOn( self ) and self.canFocusOn then
		self.parent:drawRectWire( self.outRegion.x, self.outRegion.y, self.outRegion.width, self.outRegion.height, 0xff0000 )
	end
end

function Component:onMouseMotion ( evt )
end

function Component:onMouseUp ( evt )
end

function Component:onMouseDown ( evt )
end

function Component:onClick ( evt )
end

function Component:onDrag ( evt )
end

function Component:onKeyDown ( evt )
end

function Component:onKeyUp ( evt )
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