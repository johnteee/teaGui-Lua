local sdl = require( "ffi/sdl" )
local Component = require( "component" )
local band = bit.band
local Textfield = Component:new{
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
	local eventType = self:detectEvent( evt )
	
	if( eventType ~= "nothing") then
		self.parent:focusOn( self )
	end
	
	if( eventType == "change") then
		self:onChange ( evt )
	end
end

function Textfield:detectEvent ( evt )
	local xspace, yspace = 8, 8
	
	self.parent:checkHitOn( self, self.x - xspace/2, self.y - yspace/2, self.width, self.height )
	
	if self.parent:isFocusOn( self ) then
		self.parent:drawRect( self.x-xspace*3/4, self.y-yspace*3/4, self.width + (xspace*4/4), self.height + (yspace*4/4), 0xff0000 )
	end
	
	if self.parent:isMouseHover( self ) then
		if self.parent:isMousePress( self ) then
			self.parent:drawRect( self.x - xspace/2, self.y - yspace/2, self.width + xspace/2, self.height + yspace/2, 0xcccccc )
		else
			self.parent:drawRect( self.x - xspace/2, self.y - yspace/2, self.width + xspace/2, self.height + yspace/2, 0xaaaaaa )
		end
	else
		self.parent:drawRect( self.x - xspace/2, self.y - yspace/2, self.width + xspace/2, self.height + yspace/2, 0x777777 )
	end
	
	local str = self.buffer
	self.parent:drawString( str, self.x, self.y )
	
	if self.parent:isFocusOn( self ) and  self.parent:isShowCursorNow()then
		self.parent:drawString( "_", self.x + (#str)*self.parent.fontWidth, self.y )
	end
	
	self.parent:checkSwitchFocus( self )
	
	local triggerChange = false
	
	if self.parent:isFocusOn( self ) then
		if evt.keyEntered == sdl.SDLK_BACKSPACE then
			if #str > 0 then
				self:changeBuffer( string.sub(str, 1, -1 - 1) )
				triggerChange = true
			end
		elseif evt.keyChar >= 32 and evt.keyChar < 127 and (#str + 1 + 1)*self.parent.fontWidth < self.width then
			self:changeBuffer( str .. string.char(evt.keyChar) )
			triggerChange = true
		end
	end
	
	if( triggerChange ) then
		return "change"
	else
		return "nothing"
	end
end

function Textfield:changeBuffer( str )
	self.buffer = str
end

function Textfield:onChange ( evt )
end

return Textfield