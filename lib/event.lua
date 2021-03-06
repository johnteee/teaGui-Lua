package.path = package.path .. ";../?.lua;?.lua;lib/?.lua"

local Object = require( "lib.object" )

local Event = Object:extend{
	className = "Event",
	
	eventType = nil,
	
	mouseDown = false, 
	mouseX = 0, mouseY = 0, mouseButton = 0,
	
	keyEntered = 0, keyChar = 0, keyMod = false
}

return Event