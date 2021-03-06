package.path = package.path .. ";../?.lua;?.lua;lib/?.lua"

local Component = require( "lib.component" )

local min, max = math.min, math.max

--[[ Sample Code:
myComponent = Slider:create ( myUI:GenID(), 500, 40, 60, 500, 255, band( myUI.backgroundColor, 0xFF ) )
function myComponent:onChange ( evt )
	print( self.value )
	self.parent.backgroundColor = bor( band( self.parent.backgroundColor, 0xffff00 ), self.value )
end
myUI:addComponent( myComponent )

myComponent = Slider:create ( myUI:GenID(), 550, 40, 70, 300, 63, band( shiftRight( myUI.backgroundColor, 10 ), 0x3F ) )
function myComponent:onChange ( evt )
	print( self.value )
	self.parent.backgroundColor = bor( band( self.parent.backgroundColor, 0xff00ff ), shiftLeft( self.value, 10 ) )
end
myUI:addComponent( myComponent )

myComponent = Slider:create ( myUI:GenID(), 600, 40, 90, 400,  15, band( shiftRight( myUI.backgroundColor, 20 ), 0xF ) )
function myComponent:onChange ( evt )
	print( self.value )
	self.parent.backgroundColor = bor( band( self.parent.backgroundColor, 0x00ffff ), shiftLeft( self.value, 20 ) )
end
myUI:addComponent( myComponent )
]]--

local Slider = Component:extend{
	className = "Slider",
	
	maxValue = 100, value = 50,
	width = 16, height = 255,
	
	canDrag = false
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
	local eventArray, valueArray = self:super().handleEvent ( self, evt )
	local theFunc = nil
	
	if( eventArray["change"] ) then
		self.value = valueArray["change"]
		theFunc = self.onChange
		self.parent:createEventThreadAndStart( theFunc, self, evt )
	end
end

function Slider:detectEvent ( evt )
	self.hitRegion.x, self.hitRegion.y, self.hitRegion.width, self.hitRegion.height =
	self.x+self.xspace, self.y+self.yspace, self.width, self.height
	
	local platformConst = self.parent:getPlatformConst()
	local triggerChange = false
	if self.parent:isFocusOn( self ) then
		if self.parent:isKeyEntered( evt, platformConst.KEYUP ) then
			if self.value > 0 then
				self.value = self.value - 1
				triggerChange = true
			end
		elseif self.parent:isKeyEntered( evt, platformConst.KEYDOWN ) then
			if self.value < self.maxValue then
				self.value = self.value + 1
				triggerChange = true
			end
		end
	end
	
	if self.parent:isMousePress( self ) then
		local mousePosition = evt.mouseY - ( self.y + self.yspace )
		mousePosition = max( mousePosition, 0 )
		mousePosition = min( mousePosition, self.height )
		local v = mousePosition * self.maxValue / self.height
		if v ~= self.value then
			self.value = v
			triggerChange = true
		end
	end
	
	local eventArray, valueArray = self:super().detectEvent( self, evt )
	
	if triggerChange == true then
		eventArray["change"] = "change"
		valueArray["change"] = self.value
	end
	
	return eventArray, valueArray
end

function Slider:paint ()
	local yvarspace = (self.height/16)/2
	local ypos = (self.height + 1 - self.yspace*2) * self.value / self.maxValue
	
	self:setOutRegion( self.x-self.xspace/2, self.y-self.yspace/2, self.width + self.xspace*3, self.height + yvarspace*2+self.yspace+1 )
	
	self:super().paint( self )
	
	self.parent:drawRect( self.x,self.y, self.width+self.xspace*2, self.height+yvarspace*2, 0x777777 )
	
	if self.parent:isMouseHover( self ) then
		if self.parent:isMousePress( self ) then
			self.parent:drawRect( self.x+self.xspace, self.y+self.yspace + ypos, self.width, yvarspace*2, 0x444444 )
		else
			self.parent:drawRect( self.x+self.xspace, self.y+self.yspace + ypos, self.width, yvarspace*2, 0xffffff )
		end
	else
		self.parent:drawRect( self.x+self.xspace, self.y+self.yspace + ypos, self.width, yvarspace*2, 0xaaaaaa )
	end
end

function Slider:onChange ( evt )
end

return Slider