local Object = require( "object" )

local Component = Object:new{
	x = 0, y = 0,
	width = 0, height = 0,
	
	ID = nil,
	parent = nil
}

function Component:handleEvent ( evt )
end

function Component:detectEvent ( evt )
end

return Component