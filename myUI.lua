-- Reference: http://sol.gfxile.net/imgui/ch06.html
--  Based on: http://sol.gfxile.net/imgui/ch06.cpp

package.path = package.path .. ";./lib/?.lua"
local teaUI = require( "teaUI" )
local Button = require( "button" )
local Slider = require( "slider" )
local Textfield = require( "textfield" )
local Image = require( "image" )

local shiftLeft, shiftRight, bor, band, min, max = bit.lshift, bit.rshift, bit.bor, bit.band, math.min, math.max

local function printIDs( self )
	print ( "active: " .. self.parent.activeItem .. " self: " .. self.ID )
end

--Create new teaUI (myUI is Global Variable)
myUI = teaUI:create()
function myUI:onMouseDown ( evt )
	print( "I'm myUI" ) --teaUI can get all event except drag,and it's useful for game input(global input event)
	printIDs( self )
end

--Define new Button
--Define event handling and add it into myUI
local myButton1 = Button:create ( myUI:GenID(), 50, 50 ) --at x = 50, y = 50
function myButton1:onClick ( evt )
	self.parent:randomBgColor()
	print( "Button1 click" )
end
function myButton1:onMouseDown ( evt )
	print("My Super classes")
	for i = 1, #(self.mysuper) do
		print(self.mysuper[i].className)
	end
	print("I'm a " .. self.className)
end
function myButton1:onKeyUp ( evt )
	print( "Button1 KeyUp" )
end
myUI:addComponent( myButton1 )

--Define new Button
--Define event handling and add it into myUI
local myButton2 = Button:create ( myUI:GenID(), 150, 50 ) --at x = 150, y = 50
function myButton2:onClick ( evt )
	print( "Button2 Click" )
	self.parent:randomBgColor()
end
myUI:addComponent( myButton2 )

--Define new Button
--Define event handling and add it into myUI
local myButton3 = Button:create ( myUI:GenID(), 50, 150 )
function myButton3:onMouseDown ( evt )
	print( "Button3 MouseDown" )
	self.parent:randomBgColor()
end
myUI:addComponent( myButton3 )

--Define new Button
--Define event handling and add it into myUI
local myButton4 = Button:create ( myUI:GenID(), 150, 150 )
myButton4.canFocusOn = false
function myButton4:onClick ( evt )
	print( "Button4 Click\nBye~" )
	self.parent:quit()
end
myUI:addComponent( myButton4 )

--Define new Text
--Define event handling and add it into myUI
local myText = Textfield:create ( myUI:GenID(), 50, 300, 300, 25) --at x = 50, y = 300, width = 300, height = 25
function myText:onKeyDown ( evt )
	print( self.buffer )
	self.parent:setTitle("Text KeyDown!")
end
function myText:onKeyUp ( evt )
	print( self.buffer )
	self.parent:setTitle("Text Changed!")
end
function myText:onDrag ( evt )
	print ( "Text Drag!" )
	printIDs( self )
	self.x, self.y = evt.mouseX - self.width/2, evt.mouseY - self.height/2
end
function myText:onMouseMotion ( evt )
	print("Text MouseMotion")
end
myUI:addComponent( myText )

--Define new Img
--Define event handling and add it into myUI
local myImg = Image:create ( myUI:GenID(), 30, 30, myUI:loadBitmap( "res/test.bmp" ) )
myImg.canFocusOn = true --Default can't Focus On in Image class
--myImg.canEventOn = false 
function myImg:onDrag ( evt )
	printIDs( self )
	print ( "MyImg Drag!" )
	self.x, self.y = evt.mouseX - self.width/2, evt.mouseY - self.height/2
end
myUI:addComponent( myImg )

--Define new Slider
--Define event handling and add it into myUI
local mySlider1 = Slider:create ( myUI:GenID(), 500, 40, 60, 500, 255, band( myUI.backgroundColor, 0xFF ) )
-- at x = 500, y = 40, width = 60, height = 500, maximum = 255, currentValue
function mySlider1:onChange ( evt )
	print( "mySlider1: " .. self.value )
	self.parent.backgroundColor = bor( band( self.parent.backgroundColor, 0xffff00 ), self.value )
end
myUI:addComponent( mySlider1 )

--Define new Slider
--Define event handling and add it into myUI
local mySlider2 = Slider:create ( myUI:GenID(), 550, 40, 70, 300, 63, band( shiftRight( myUI.backgroundColor, 10 ), 0x3F ) )
-- at x = 550, y = 40, width = 70, height = 300, maximum = 63, currentValue
function mySlider2:onChange ( evt )
	print( "mySlider2: " .. self.value )
	self.parent.backgroundColor = bor( band( self.parent.backgroundColor, 0xff00ff ), shiftLeft( self.value, 10 ) )
end
myUI:addComponent( mySlider2 )

--Define new Slider
--Define event handling and add it into myUI
local mySlider3 = Slider:create ( myUI:GenID(), 600, 40, 90, 400,  15, band( shiftRight( myUI.backgroundColor, 20 ), 0xF ) )
-- at x = 600, y = 40, width = 90, height = 400, maximum = 15, currentValue
function mySlider3:onChange ( evt )
	print( "mySlider3: " .. self.value )
	self.parent.backgroundColor = bor( band( self.parent.backgroundColor, 0x00ffff ), shiftLeft( self.value, 20 ) )
end
function mySlider3:onDrag ( evt ) --Because of Slider default settings,it can't be drag until its canDrag has been setted true.
	printIDs( self )
	if self.parent:isMousePress( self ) then
		print ( "mySlider3 drag" )
		self.x, self.y = evt.mouseX - self.width/2, evt.mouseY - self.height/2
	end
end
myUI:addComponent( mySlider3 )

myUI:start()