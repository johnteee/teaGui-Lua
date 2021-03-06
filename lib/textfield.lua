package.path = package.path .. ";../?.lua;?.lua;lib/?.lua"

local Component = require( "lib.component" )
local band = bit.band
local Textfield = Component:extend{
	className = "Textfield",
	
	width = 64, height = 48,
	buffer = "Text"
}

function Textfield:create ( ID, x, y, width, height, buffer )
	local newOne = self:new()
	newOne.ID = ID or newOne.ID
	newOne.x = x or newOne.x
	newOne.y = y or newOne.y
	newOne.width = width or newOne.width
	newOne.height = height or newOne.height
	newOne.buffer = buffer or newOne.buffer
	return newOne
end

function Textfield:handleEvent ( evt )
	local eventType, value = self:super().handleEvent ( self, evt )
	local theFunc = nil
	
	if( eventType["change"] ) then
		theFunc = self.onChange
		self.parent:createEventThreadAndStart( theFunc, self, evt )
	end
end

function Textfield:detectEvent ( evt )
	self.hitRegion.x, self.hitRegion.y, self.hitRegion.width, self.hitRegion.height =
	self.x - self.xspace/2, self.y - self.yspace/2, self.width, self.height
	
	local triggerChange = false
	local str = self.buffer
	
	if self.parent:isFocusOn( self ) then
		if self.parent:isKeyEntered( evt, self.parent:getPlatformConst().BACKSPACE ) then
			if #str > 0 then
				triggerChange = true
			end
		elseif evt.keyChar >= 32 and evt.keyChar < 127 and (#str + 1 + 1)*self.parent.fontWidth < self.width then
			triggerChange = true
		end
		self:detectInput( evt )
	end
	
	local eventArray, valueArray = self:super().detectEvent( self, evt )
	
	if( triggerChange ) then
		eventArray["change"] = "change"
		valueArray["change"] = "change"
	end
	
	return eventArray, valueArray
end

function Textfield:changeBuffer( str )
	self.buffer = str
end

function Textfield:paint ()
	self:setOutRegion( self.x-self.xspace*3/4, self.y-self.yspace*3/4, self.width + (self.xspace*4/4), self.height + (self.yspace*4/4) )
	self:super().paint( self )
	
	if self.parent:isMouseHover( self ) then
		if self.parent:isMousePress( self ) then
			self.parent:drawRect( self.x - self.xspace/2, self.y - self.yspace/2, self.width + self.xspace/2, self.height + self.yspace/2, 0xcccccc )
		else
			self.parent:drawRect( self.x - self.xspace/2, self.y - self.yspace/2, self.width + self.xspace/2, self.height + self.yspace/2, 0xaaaaaa )
		end
	else
		self.parent:drawRect( self.x - self.xspace/2, self.y - self.yspace/2, self.width + self.xspace/2, self.height + self.yspace/2, 0x777777 )
	end
	
	local str = self.buffer
	self.parent:drawString( str, self.x, self.y )
	
	if self.parent:isFocusOn( self ) and  self.parent:isShowCursorNow()then
		self.parent:drawString( "_", self.x + (#str)*self.parent.fontWidth, self.y )
	end
end

function Textfield:detectInput( evt )
	local str = self.buffer
	if self.parent:isKeyEntered( evt, self.parent:getPlatformConst().BACKSPACE ) then
			if #str > 0 then
				self:changeBuffer( string.sub(str, 1, -1 - 1) )
			end
		elseif evt.keyChar >= 32 and evt.keyChar < 127 and (#str + 1 + 1)*self.parent.fontWidth < self.width then
			self:changeBuffer( str .. string.char(evt.keyChar) )
	end
end

function Textfield:onChange ( evt )
end

return Textfield