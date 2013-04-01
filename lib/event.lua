local Object = require( "object" )

local Event = Object:extend{
	mouseDown = false, 
	mouseX = 0, mouseY = 0,
	keyEntered = 0, keyChar = 0, keyMod = false
}

return Event