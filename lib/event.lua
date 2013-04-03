local Object = require( "object" )

local Event = Object:extend{
	eventType = nil,
	
	mouseDown = false, 
	mouseX = 0, mouseY = 0, mouseButton = 0,
	
	keyEntered = 0, keyChar = 0, keyMod = false
}

return Event