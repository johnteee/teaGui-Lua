-- Reference: http://sol.gfxile.net/imgui/ch06.html
--  Based on: http://sol.gfxile.net/imgui/ch06.cpp

package.path = package.path .. ";./lib/?.lua"
local teaUI = require( "teaUI" )
local Button = require( "button" )
local Slider = require( "slider" )
local Textfield = require( "textfield" )
local Image = require( "image" )

local shiftLeft, shiftRight, bor, band, min, max = bit.lshift, bit.rshift, bit.bor, bit.band, math.min, math.max

myUI = teaUI:create()

local function printIDs( self )
	print ( "active: " .. self.parent.activeItem .. " self: " .. self.ID )
end

local myComponent

myComponent = myUI
function myComponent:onMouseDown ( evt )
	printIDs( self )
end

myComponent = Button:create ( myUI:GenID(), 50, 50 )
function myComponent:onClick ( evt )
	self.parent:randomBgColor()
	print( 1 )
end
function myComponent:onMouseDown ( evt )
	for i = 1, #(self.mysuper) do
		print(self.mysuper[i].className)
	end
	print(self.className)
end
function myComponent:onKeyUp ( evt )
	print( 2 )
end
myUI:addComponent( myComponent )

myComponent = Button:create ( myUI:GenID(), 150, 50 )
function myComponent:onClick ( evt )
	self.parent:randomBgColor()
end
myUI:addComponent( myComponent )

myComponent = Button:create ( myUI:GenID(), 50, 150 )
function myComponent:onMouseDown ( evt )
	self.parent:randomBgColor()
end
myUI:addComponent( myComponent )

myComponent = Button:create ( myUI:GenID(), 150, 150 )
myComponent.canFocusOn = false
function myComponent:onClick ( evt )
	self.parent:quit()
end
myUI:addComponent( myComponent )

myComponent = Textfield:create ( myUI:GenID(), 50, 300, 300, 25)
function myComponent:onKeyDown ( evt )
	print( self.buffer )
	self.parent:setTitle("KeyDown!")
end
function myComponent:onKeyUp ( evt )
	print( self.buffer )
	self.parent:setTitle("Text Changed!")
end
function myComponent:onDrag ( evt ) printIDs( self )
	if self.parent:isMousePress( self ) then print ( "123" )
		self.x, self.y = evt.mouseX - self.width/2, evt.mouseY - self.height/2
	end
end
function myComponent:onMouseMotion ( evt )
	print("Move")
end
myUI:addComponent( myComponent )

myComponent = Image:create ( myUI:GenID(), 30, 30, myUI:loadBitmap( "res/test.bmp" ) )
myComponent.canFocusOn = true
--myComponent.canEventOn = false
function myComponent:onDrag ( evt ) printIDs( self )
	if self.parent:isMousePress( self ) then print ( "123" )
		self.x, self.y = evt.mouseX - self.width/2, evt.mouseY - self.height/2
	end
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
function myComponent:onDrag ( evt ) print ( self.parent.activeItem .. " " .. self.ID )
	if self.parent:isMousePress( self ) then print ( "123" )
		self.x, self.y = evt.mouseX - self.width/2, evt.mouseY - self.height/2
	end
end
myUI:addComponent( myComponent )

myUI:start()