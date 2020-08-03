map = {}

function map.new(w, h, c)
	local bump = require 'scripts.bump'
	local Map = {camx = 0, camy=0, width = w or 640, height = h or 480, bg = c or {0.1, 0.5, 0}, scale=math.min(WINDOW_WIDTH/640, WINDOW_HEIGHT/480), target=nil, fov=0.3, objects={}, images_bg={}, images_fg={}, world = bump.newWorld(64), Time = 0,
		set = function(self, w, h, c)
			self.width = w
			self.height = h
			self.bg = c
		end, 
		
		draw_base = function(self)
			love.graphics.setColor(self.bg[1], self.bg[2], self.bg[3])
			love.graphics.rectangle("fill", 0, 0, self.width , self.height)
			love.graphics.setColor(1, 1, 1)
		end,
		
		draw_tile = function(self)
			local x = 0
			local y = 0
			local th = self.tile:getHeight()
			local tw = self.tile:getWidth()
			while y <= self.height do
				x = 0
				while x <= self.width do
					love.graphics.draw(self.tile, x, y)
					x = x + tw
				end
				y = y + th 
			end
		end,
		
		spawn = function(self, stuff) 
			for i, v in ipairs(stuff) do				
				local obj = v[1]
				for n, pos in ipairs(v[2]) do
					local s = obj():at(pos[1], pos[2])
					table.insert(self.objects, s)
					s.map = self
				end
			end
		end,
		
		detail = function(self, stuff)
			for i, v in ipairs(stuff) do				
				local obj = v[1]
				for n, pos in ipairs(v[2]) do
					local s = obj():at(pos[1], pos[2])					
					if v.z then
						table.insert(self.images_fg, s)
					else	
						table.insert(self.images_bg, s)
					end
					s.map = self
				end
			end
		end,
		
		design = function(self, obj)			
			for i, v in ipairs(obj) do
				table.insert(self.objects, v)
				v.map = self
			end			
		end,
		
		decorate = function(self, obj)
			for i, v in ipairs(obj) do
				if v.z then
					table.insert(self.images_fg, v)
				else	
					table.insert(self.images_bg, v)
				end
			end
		end,
		
		add_bump = function(self)		
			for i, v in ipairs(self.objects) do				
				v.bump = {name = v.name}
				if v.hitbox and v.hitbox.mask ~= true then
					self.world:add(v.bump, v.x + v.hitbox.offx, v.y + v.hitbox.offy, v.hitbox.width, v.hitbox.height)
				end
			end
		end,
		
		clear = function(self)
			self:delete_bump()
			self.objects = {}
			self.images_bg = {}
			self.images_fg = {}			
		end,
		
		delete_bump = function(self)		
			local items, lenb = self.world:getItems()
			for i, v in ipairs(items) do
				self.world:remove(v)				
			end			
		end,
		
		switch = function(self, other)
			local items, len = self.world:getItems()
			for i, v in ipairs(items) do
				self.world:remove(v)				
			end			
			myMap = other				
		end, 
		
		delete = function(self, obj)			
			local items, lenb = self.world:getItems()
			for i, v in ipairs(items) do
				if v.name == obj.name then			
					obj.hitbox = nil
					obj.bump = nil										
				end
			end					
			for i, v in ipairs(self.objects) do
				if v == obj then
					v.x = 0					
					table.remove(self.objects, i)
					break
				end
			end	
			for i, v in ipairs(self.images_bg) do
				if v == obj then
					v.x = 0					
					table.remove(self.images_bg, i)
					break
				end
			end
			
			
		end,
		
		
		update = function(self, delta)			
			for i, v in ipairs(self.objects) do				
				v:update(delta)						
				if v.hitbox then
					if v.hitbox.mask == true then
						v.x, v.y, cols, col_len = self.world:move(v.bump, v.mapx, v.mapy)
					else 						
						v.x, v.y, cols, col_len = self.world:move(v.bump, v.mapx + v.hitbox.offx, v.mapy + v.hitbox.offy)
						v.y = v.y - v.hitbox.offy
						v.x = v.x - v.hitbox.offx
					end
					v.mapx = v.x 
					v.mapy = v.y					
					
					for i=1, col_len do 
						local col = cols[i]
						if v.name == 'monster' and col.other.name == 'player' then
							print('game over')
							gameover = true							
							for i, v in ipairs(self.objects) do
								pcall(self.delete, v)
							end
							pcall(self.delete_bump)
							pause = true
						end
					end					
				else
					v.x = v.mapx 
					v.y = v.mapy 
				end
			end
			
			if self.target then
				if self.target.mapx - self.camx >  WINDOW_WIDTH / self.scale * (1 - self.fov) then
					self.camx = self.target.mapx -  WINDOW_WIDTH / self.scale * (1 - self.fov)
				elseif self.target.mapx - self.camx <  WINDOW_WIDTH / self.scale * self.fov then
					self.camx = self.target.mapx -  WINDOW_WIDTH / self.scale * self.fov
				end
				
				if self.target.mapy - self.camy > WINDOW_HEIGHT / self.scale * (1 - self.fov) then
					self.camy = self.target.mapy -  WINDOW_HEIGHT / self.scale * (1 - self.fov)
				elseif self.target.mapy - self.camy <  WINDOW_HEIGHT / self.scale * self.fov then
					self.camy = self.target.mapy -  WINDOW_HEIGHT / self.scale * self.fov
				end
				
				self.soffx = self.target.x - (WINDOW_WIDTH / 2) / self.scale
				self.soffy = self.target.y - (WINDOW_HEIGHT / 2) / self.scale
				
				if self.width > WINDOW_HEIGHT / self.scale and self.height > WINDOW_HEIGHT / self.scale then
					if self.camx < 0 then self.camx = 0 end
					if self.camy < 0 then self.camy = 0 end
					if self.camx > self.width - WINDOW_WIDTH / self.scale then self.camx = self.width - WINDOW_WIDTH / self.scale end
					if self.camy > self.height - WINDOW_HEIGHT / self.scale then self.camy = self.height - WINDOW_HEIGHT / self.scale end			
				else					
					self.camx = (self.width - WINDOW_WIDTH / self.scale) / 2
					self.camy = WINDOW_HEIGHT - self.height * self.scale
				end				
				if gamestate == 'banner' then
				
					self.camx = (self.width - WINDOW_WIDTH / self.scale) / 2
					self.camy = WINDOW_HEIGHT - self.height * self.scale
				end
			end
			
			self.Time = self.Time + delta
			myShader:send("time", self.Time)			
			if gamestate == 'game' and self.Time > 5 and (math.floor(self.Time % 10) % 2)==0 and math.floor(self.Time * 10) ~= self.boo then			
				self.boo = math.floor(self.Time * 10)
				local rp = love.math.random(1, 4)
				local monster = {}				
				if rp == 1 then
					rx = love.math.random(1, self.width - 1)
					ry = -1
					monster.dir = vector.new(love.math.random(-10, 10), love.math.random(0, 20))
				elseif rp == 2 then
					rx = self.width + 1 
					ry = love.math.random(1, self.height - 1)
					monster.dir = vector.new(love.math.random(-20, 0), love.math.random(-10, 10))
				elseif rp == 3 then
					rx = love.math.random(1, self.width - 1)
					ry = self.height + 1 
					monster.dir = vector.new(love.math.random(-10, 10), love.math.random(-20, 0))
				elseif rp == 4 then
					rx = -1					
					ry = love.math.random(1, self.height - 1)
					monster.dir = vector.new(love.math.random(0, 20), love.math.random(-10, 10))
				end
				local luck = love.math.random(1, 100)
				if luck < 1 + (timer / 7) then
					noob = monster1.new():at(rx, ry)
				else
					noob = monster2.new():at(rx, ry)
				end
				noob.dir = monster.dir
				table.insert(self.objects, noob)
				noob.map = self
				noob.bump = {name = noob.name}
				if noob.hitbox and noob.hitbox.mask ~= true then
					self.world:add(noob.bump, noob.x + noob.hitbox.offx, noob.y + noob.hitbox.offy, noob.hitbox.width, noob.hitbox.height)
				end
			end
		end,
		
		draw = function(self)
			love.graphics.scale(self.scale)
			love.graphics.translate(-math.floor(self.camx), -math.floor(self.camy))			
			self:draw_base()
			table.sort(self.objects, function(a, b) return a.z_index < b.z_index end)
			
			--send information to shader
			local light_no = 0		
			for i, v in ipairs(self.objects) do			
				if v.light then
					local name = "lights[" .. light_no .."]"
				    myShader:send(name .. ".position", {v.light.x() * self.scale, v.light.y() * self.scale}) 
				    myShader:send(name .. ".diffuse", v.light.color())
				    myShader:send(name .. ".power", v.light.power())
					light_no = light_no + 1				
				end
			end
			for i, v in ipairs(self.images_bg) do			
				if v.light then
					local name = "lights[" .. light_no .."]"
				    myShader:send(name .. ".position", {v.light.x() * self.scale, v.light.y() * self.scale}) 
				    myShader:send(name .. ".diffuse", v.light.color())
				    myShader:send(name .. ".power", v.light.power())
					light_no = light_no + 1					
				end
			end
			if light_no > 0 then
				myShader:send("num_lights", light_no)
			end
			
			--draw the objects
			for i, v in ipairs(self.images_bg) do
				v:draw()
			end
			for i, v in ipairs(self.objects) do			
				v:draw()
			end
			for i, v in ipairs(self.images_fg) do
				v:draw()
			end
		end
	}
	return Map
end