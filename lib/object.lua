local Object = {}

function Object:new ( obj )
	obj = obj or {}
	setmetatable( obj, self )
	self.__index = self
	return obj
end

function Object:extend ( obj )
	obj = self:new ( obj )
	
	obj.mysuper = self
	return obj
end

function Object:super ()
	return self.mysuper
end

return Object