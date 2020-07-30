image = {}

function image.new(img)
	local Image = { x = 0, y = 0, image = img, width = img:getWidth(), height = img:getHeight(),
	at = function(self, x, y, z)
		self.x = x
		self.y = y
		self.mapx = x
		self.mapy = y
		self.z = z
		return self
	end,
	
	Rect = function(self)		
		return rect.new(self.x, self.y, self.width, self.height)		
	end,
	
	draw = function(self)
		love.graphics.draw(self.image, self.x - self.width / 2, self.y - self.height / 2)
	end
	}
	return Image
end