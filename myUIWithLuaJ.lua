-- Reference: http://sol.gfxile.net/imgui/ch06.html
--  Based on: http://sol.gfxile.net/imgui/ch06.cpp

package.path = package.path .. ";../?.lua;?.lua;lib/?.lua"

local JSwingUIDriver = require( "lib.jframeuidriver" ) --Load Driver first,because of many platform dependencies in it
local teaUI = require( "lib.teaUI" )
local Button = require( "lib.button" )
local Slider = require( "lib.slider" )
local Textfield = require( "lib.textfield" )
local Image = require( "lib.image" )

local shiftLeft, shiftRight, bor, band, min, max = bit.lshift, bit.rshift, bit.bor, bit.band, math.min, math.max

local function printIDs( self )
	print ( "Pressed: " .. self.parent.pressedItem .. " Self: " .. self.ID )
end

--Create new teaUI (myUI is Global Variable)
myUI = teaUI:create( JSwingUIDriver:new(), 800, 600 ) --Use UIDriver
myUI.loopDelay = 10 -- delay
myUI.showFPS = true -- Show FPS
function myUI:onMouseDown ( evt )
	print( "I'm myUI" ) --teaUI can get all event except drag,and it's useful for game input(global input event)
	printIDs( self )
end

--myUI:start()