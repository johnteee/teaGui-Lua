local Object = {}

function Object:new ( obj )
	obj = obj or {}
	setmetatable( obj, self )
	self.__index = self
	return obj
end

function Object:extend ( obj )
	obj = self:new ( obj )
	
	obj.mysuper = obj.mysuper or {}
	local mysuper = obj.mysuper
	obj.mysuper[#mysuper + 1] = self
	return obj
end

function Object:super ()
	local mysuper = self.mysuper
	return self.mysuper[#mysuper]
end

return Object