local Object = { className = "Object" }

function Object:new ( obj )
	obj = obj or {}
	setmetatable( obj, self )
	self.__index = self
	return obj
end

function Object:extend ( obj )
	obj = self:new ( obj )
	
	obj.mysuper = {}
	local oldmysuper = self.mysuper or {}
	
	if #oldmysuper > 0 then
		for i = 1, #oldmysuper do
			obj.mysuper[i] = oldmysuper[i]
		end
	end
	
	obj.mysuper[#oldmysuper + 1] = self
	return obj
end

function Object:super ()
	return self.mysuper[#(self.mysuper)]
end

return Object