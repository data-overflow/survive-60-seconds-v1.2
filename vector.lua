vector = {}

function vector.new(X, Y)
	local Vector = { x = X or 0, y = Y or 0,
		new = function(self, x, y)
			self.x = x
			self.y = y
		end,
		add = function(self, x, y)
			self.x = self.x + x
			self.y = self.y + y
		end,
		mag = function(self, x, y)
			return ((self.x^2)+(self.y^2))^0.5
		end,
		normalize = function(self)
			local m = self:mag()
			self.x = self.x / m
			self.y = self.y / m
		end
	}
	return Vector
end