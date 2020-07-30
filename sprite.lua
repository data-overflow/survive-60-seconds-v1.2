require 'rect'

sprite = {}

function sprite.new(n)
	local Sprite = { name = n, 
	x = 0, y = 0, mapx = 0, mapy = 0, z_index = 0, group = 'object', animation = {}, animations = {}, frame = 1, playing = false,
	
	at = function(self, x, y)
		self.mapx = x or self.mapx
		self.mapy = y or self.mapy
		self.x = x or self.x
		self.y = y or self.y
		return self
	end,
	
	set_image = function(self, img)
		self.image = img
		self.height = img:getHeight()
		self.width = img:getWidth()
	end, 
	
	Rect = function(self)
		if self.shape then
			return rect.new(self.mapx+self.shape[1], self.mapy+self.shape[2], self.shape[3], self.shape[4])
		elseif self.hitbox then
			return rect.new(self.x+self.hitbox.offx, self.y+self.hitbox.offy, self.hitbox.width, self.hitbox.height)
		else
			return rect.new(self.x, self.y, self.width, self.height)
		end
	end,
	
	collided_with = function(self, other)
		return self:Rect():collide_rect(other:Rect())
	end,
	
	collided_group = function(self, grp)
		for i, v in ipairs(self.map.objects) do
			if v.group == grp and self:collided_with(v) then
				return true, v:Rect()
			end
		end
		for i, v in ipairs(self.map.images_bg) do
			if v.group == grp and self:collided_with(v) then
				return true, v
			end
		end
		return false
	end,
	
	add_animation = function(self, name, images, delay, loop)
		table.insert(self.animations, {NAME = name, IMAGES = images, DELAY = delay, LOOP = loop, FRAMES = #images})
	end,
	
	play = function(self, name)
		for i, v in ipairs(self.animations) do
			if v.NAME == name then
				self.animation = v
			end
		end
		self.frame = 1
		self:set_image(self.animation.IMAGES[1])
		self.playing = true
	end,
	
	update_anim = function(self)
		self.z_index = self.y + self.height
		if self.playing and self.animation.DELAY then
			self.frame = self.frame + 1 / (love.timer.getFPS() * self.animation.DELAY)
			if self.frame >= self.animation.FRAMES+1 then
				if self.animation.LOOP then self.frame = 1 
				else self.frame = self.animation.FRAMES end
			end
			self:set_image(self.animation.IMAGES[math.floor(self.frame)]) --set_image
		end
	end,
	
	update = function(self, dt)
		self:update_anim()
	end,
	
	draw = function(self)
		love.graphics.draw(self.image, self.x-self.width/2, self.y-self.height/2)
	end
	}
	return Sprite
end

simplesprite = {}

function simplesprite.new(img)
	local SimpleSprite = {
	x = 0, y = 0, mapx = 0, mapy = 0, z_index = 0, image = img, height = img:getHeight(), width = img:getWidth(),
	
	at = function(self, x, y)
		self.mapx = x or self.mapx
		self.mapy = y or self.mapy
		self.x = x or self.x
		self.y = y or self.y
		return self
	end,
	
	set_image = function(self, img)
		self.image = img
		self.height = img:getHeight()
		self.width = img:getWidth()
	end, 
	
	Rect = function(self)
		if self.shape then
			return rect.new(self.mapx+self.shape[1], self.mapy+self.shape[2], self.shape[3], self.shape[4])
		elseif self.hitbox then
			return rect.new(self.x+self.hitbox.offx, self.y+self.hitbox.offy, self.hitbox.width, self.hitbox.height)
		else
			return rect.new(self.x, self.y, self.width, self.height)
		end
	end,
	
	collided_with = function(self, other)
		return self:Rect():collide_rect(other:Rect())
	end,
	
	collided_group = function(self, grp)
		for i, v in ipairs(self.map.objects) do
			if v.group == grp and self:collided_with(v) then
				return true, v:Rect()
			end
		end
		return false
	end,
	
	update_anim = function(self)
		self.z_index = self.y + self.height		
	end,
	
	update = function(self, dt)
		self:update_anim()
	end,
	
	draw = function(self)
		love.graphics.draw(self.image, self.x-self.width/2, self.y-self.height/2)
	end
	}
	return SimpleSprite
end