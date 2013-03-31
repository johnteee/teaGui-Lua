-- Reference: http://sol.gfxile.net/imgui/ch06.html
--  Based on: http://sol.gfxile.net/imgui/ch06.cpp

package.path = package.path .. ";./lib/?.lua"
local teaUI = require( "teaUI" )
local Button = require( "button" )
local Slider = require( "slider" )
local Textfield = require( "textfield" )

local shiftLeft, shiftRight, bor, band, min, max = bit.lshift, bit.rshift, bit.bor, bit.band, math.min, math.max

myUI = teaUI:new()

local myComponent

myComponent = Button:create ( myUI:GenID(), 50, 50 )
function myComponent:onClick ( evt )
	self.parent:randomBgColor()
end
myUI:addComponent( myComponent )

myComponent = Button:create ( myUI:GenID(), 150, 50 )
function myComponent:onClick ( evt )
	self.parent:randomBgColor()
end
myUI:addComponent( myComponent )

myComponent = Button:create ( myUI:GenID(), 50, 150 )
function myComponent:onClick ( evt )
	self.parent:randomBgColor()
end
myUI:addComponent( myComponent )

myComponent = Button:create ( myUI:GenID(), 150, 150 )
function myComponent:onClick ( evt )
	self.parent:quit()
end
myUI:addComponent( myComponent )

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

myComponent = Textfield:create ( myUI:GenID(), 50, 300, 100, 50)
function myComponent:onChange ( evt )
	print( self.buffer )
	self.parent:setTitle("Text Changed!")
end
myUI:addComponent( myComponent )

myUI:start()