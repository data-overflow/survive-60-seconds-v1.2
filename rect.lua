rect = {}

function rect.new(x, y, w, h)
	local Rect = {
		left = x, 
		right = x + w,
		top = y,
		bottom = y + h,
		
		collide_rect = function(self, other)
			return self.left < other.right and self.top < other.bottom and self.right > other.left and self.bottom > other.top
		end
	}
	return Rect
end