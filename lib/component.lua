local Object = require( "object" )

local Component = Object:new{
	x = 0, y = 0,
	width = 0, height = 0,
	
	ID = 0,
	parent = nil,
	canFocusOn = true
}

function Component:handleEvent ( evt )
end

function Component:detectEvent ( evt )
end

return Component