local Object = require( "object" )

local Event = Object:new{
	mouseDown = false, 
	mouseX = 0, mouseY = 0,
	keyEntered = 0, keyMod = false
}

return Event