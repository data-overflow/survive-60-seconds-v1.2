--gameobjects.lua

LIGHT = love.graphics.newImage('assets/light.png')
GMONSTER = {
	walk1 = love.graphics.newImage('assets/player/gmonster1.png'),
	walk2 = love.graphics.newImage('assets/player/gmonster2.png')
	}

RMONSTER = {
	walk1 = love.graphics.newImage('assets/player/rmonster1.png'),
	walk2 = love.graphics.newImage('assets/player/rmonster2.png')
	}

light = {
	new = function() 
		local l = image.new(LIGHT) 		
		l.start = love.timer.getTime()
		l.group = 'light'
		l.light = {x = function() return l.x - l.map.camx end, y = function() return l.y - l.map.camy end, color = function() if l.light.power() > 150 then myMap:delete(l) end return {1, 1, 1} end, power = function() return 60 * (love.timer.getTime() - l.start + 1)/8 end}
		return l
	end
}

monster1 = { --following monster
	new = function() 
		local monster = sprite.new('monster')		
		monster.speed = 80
		monster:add_animation('idle', {RMONSTER.walk1}) 
		monster:add_animation('walk', {RMONSTER.walk2, RMONSTER.walk1}, 0.2, true)
		monster:play('walk')		
		monster.hitbox = {offx = 0, offy = monster.height / 2, width = monster.width, height = monster.height / 2}
		monster.dir = vector.new()
		--monster.light = {x = function() return monster.x - monster.map.camx end, y = function() return monster.y - monster.map.camy end, color = function() return {1, 0, 0} end, power = function() return 500 + timer end}		
		monster.update = function(self, delta)
			self:update_anim()		
			self.z_index = self.y + self.height			
			local velocity = vector.new(player.x - self.x, player.y - self.y)
			if velocity:mag() > 0 then
				velocity:normalize()
				self.dir = inherit(velocity)
				if self.animation.NAME == 'idle' then self:play('walk') end
			else
				self:play('idle')
			end
			
			local c, l = self:collided_group('light')
			if c then
				l.light.color = function() if l.light.power() > 150 then myMap:delete(l) end return {1, 1 / (love.timer.getTime() - l.start), 1 / (love.timer.getTime() - l.start)} end
				myMap:delete(self)
				myMap:delete_bump()
				myMap:add_bump()
			end
			if self.x > myMap.width + 1 or self.x < -1 or self.y > myMap.height + 1 or self.y < -1 then				
				myMap:delete(self)	
				myMap:delete_bump()
				myMap:add_bump()				
			end					
			self.mapx = self.mapx + (velocity.x * self.speed * delta)
			self.mapy = self.mapy + (velocity.y * self.speed * delta)
		end
		
		return monster
	end
}
monster2 = { --random monster
	new = function() 
		local monster = sprite.new('monster')
		monster.speed = love.math.random(80, 200 + timer)
		monster:add_animation('idle', {GMONSTER.walk1}) 
		monster:add_animation('walk', {GMONSTER.walk2, GMONSTER.walk1}, 0.2, true)
		monster:play('walk')
		monster.hitbox = {offx = 0, offy = monster.height / 2, width = monster.width / 2, height = monster.height / 2}
		monster.update = function(self, delta)
			self:update_anim()		
			self.z_index = self.y + self.height
			local velocity = self.dir 
			if velocity:mag() > 0 then
				velocity:normalize()
				self.dir = inherit(velocity)
				if self.animation.NAME == 'idle' then self:play('walk') end
			else
				self:play('idle')
			end
			
			local c, l = self:collided_group('light')
			if c then
				l.light.color = function() if l.light.power() > 150 then myMap:delete(l) end return {1, 1 / (love.timer.getTime() - l.start), 1 / (love.timer.getTime() - l.start)} end
				myMap:delete(self)
				myMap:delete_bump()
				myMap:add_bump()
			end
			if self.x > myMap.width + 10 or self.x < -10 or self.y > myMap.height + 10 or self.y < -10 then				
				myMap:delete(self)
				myMap:delete_bump()
				myMap:add_bump()				
			end					
			self.mapx = self.mapx + (velocity.x * self.speed * delta)
			self.mapy = self.mapy + (velocity.y * self.speed * delta)
		end
		
		return monster
	end
}