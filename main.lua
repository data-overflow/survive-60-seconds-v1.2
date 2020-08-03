--SURVIVE 60 SECONDS v1.2
function love.load()
	print('[INFO] STARTING GAME...')
	love.graphics.setColor(0, 0, 0)
	love.graphics.setBackgroundColor(0, 0, 0)
	
	WINDOW_WIDTH = love.graphics.getWidth()
	WINDOW_HEIGHT = love.graphics.getHeight()
	
	ICON = love.image.newImageData('assets/icon.png')
	love.window.setIcon(ICON)
	
	music = love.audio.newSource('audio/horror.mp3', 'static')
	rain = love.audio.newSource('audio/thunderstorm.mp3', 'stream')
	rain:setLooping(true)
	music:setLooping(true)
	music:play()
	rain:stop()
	
	-- Creating essential classes
	InputMap = {
		['up'] = {function() return love.keyboard.isDown('up') end, function() return love.keyboard.isDown('w') end},
		['down'] = {function() return love.keyboard.isDown('down') end, function() return love.keyboard.isDown('s') end},
		['left'] = {function() return love.keyboard.isDown('left') end, function() return love.keyboard.isDown('a') end},
		['right'] = {function() return love.keyboard.isDown('right') end, function() return love.keyboard.isDown('d') end},
		['X'] = {function() return love.keyboard.isDown('z') end},
		['A'] = {function() return love.keyboard.isDown('x') end},
		['pause'] = {function() return love.keyboard.isDown('escape') end, function() return love.keyboard.isDown('p') end},
		['accept'] = {function() return love.keyboard.isDown('return') end, function() return love.keyboard.isDown('space') end, function() return love.keyboard.isDown('c') end}
	}
	
	Input = {
		update = function(self)
			for key, value in pairs(InputMap) do
				local result = false
				for i, v in ipairs(value) do
					result = result or v()
				end
				self[key] = result
			end
		end
	}
	
	require 'shader'
	require 'sprite'
	require 'image'
	require 'vector'
	require 'map'
	bump = require 'scripts.bump'
	
	--loading assets
	player_animations = {
		walk1 = love.graphics.newImage('assets/player/default1.png'),
		walk2 = love.graphics.newImage('assets/player/default2.png')
	}
	
	player = sprite.new('player')
	player.x = 30
	player.y = 40
	player.speed = 200
	player:add_animation('idle', {player_animations.walk1}) 
	player:add_animation('walk', {player_animations.walk2, player_animations.walk1}, 0.2, true)
	player:play('walk')
	player.hitbox = {offx = 0, offy = player.height / 2, width = player.width, height = player.height / 2}
	player.dir = vector.new()
	player.plant = 0
	player.boost = 0
	player.light = {x = function() return player.x - player.map.camx end, y = function() return player.y - player.map.camy end, color = function() return {1, 0.6, 0.6} end, power = function() return 150 - player.plant end}
	
	player.update = function(self, delta)
		self:update_anim()
		local velocity = vector.new()
		velocity.x = 0
		velocity.y = 0
		if Input['up'] then velocity:add(0, -1) end
		if Input['down'] then velocity:add(0, 1) end
		if Input['left'] then velocity:add(-1, 0) end
		if Input['right'] then velocity:add(1, 0) end		
		if Input['X']  then
			if self.boost < 1000 then 
				self.speed = self.speed + self.boost 
				self.boost = self.boost + 200
			else 
				self.speed = 100 
			end
		else 
			self.speed = 200 
			self.boost = 0
		end
		
		if Input['A'] then 
			if linv > 0 then
				if velocity:mag() > 0.5 then
					self.plant = self.plant + 0.5
				else
					self.plant = self.plant + 2
				end
			end
			if self.plant > 100 then
				local light = light.new():at(self.x, self.y)
				table.insert(myMap.images_bg, light)
				light.map = myMap				
				self.plant = 0
				linv = linv - 1
			end		
		else
			self.plant = 0
		end
		if velocity:mag() > 0 then
			velocity:normalize()
			self.dir = inherit(velocity)
			if self.animation.NAME == 'idle' then self:play('walk') end
		else
			self:play('idle')
		end
		
		if self.x > myMap.width then
			self.mapx = myMap.width
			self.x = myMap.width
		end
		if self.x < 0 then
			self.mapx = 0
			self.x = 0
		end
		if self.y > myMap.height then
			self.mapy = myMap.height
			self.y = myMap.height
		end
		if self.y < 0 then
			self.mapy = 0
			self.y = 0
		end
		
		self.mapx = self.mapx + (velocity.x * self.speed * delta)
		self.mapy = self.mapy + (velocity.y * self.speed * delta)
	end
	
	require 'gameobjects' 
	
	gamestate = 'banner'		
	BANNER = love.graphics.newImage('assets/banner.png')	
	TITLE = love.graphics.newImage('assets/title.png')	
	splash = image.new(BANNER)
	splash.light = {x = function() return 0 end, y = function() return 0 end, color = function() return {1, 1, 1} end, power = function() return 8 - timer * 4 end}
	
	texture = love.graphics.newImage('assets/raintex.png')
	texture:setWrap('repeat','repeat')

	local vertices = {
		{			
			0, 0, 
			0, 0,
			255, 255, 255, 10
		},
		{			
			texture:getWidth(), 0,
			1, 0, 
			255, 255, 255, 10
		},
		{			
			texture:getWidth(), texture:getHeight(),
			1, 1,
			255, 255, 255, 10
		},
		{			
			0, texture:getHeight(),
			0, 1,
			255, 255, 255, 10
		},
	}

	mesh = love.graphics.newMesh(vertices, 'fan')
	mesh:setTexture(texture)
	intensemesh = love.graphics.newMesh(vertices, 'fan')
	intensemesh:setTexture(texture)
	
	myShader = love.graphics.newShader(shader.getCode())
	myMap = map.new()
	myMap.target = splash
	myMap:decorate({splash:at(myMap.width/2, myMap.height/2)})
	font = love.graphics.getFont()
	gameover = false
	pause = false
	Font = love.graphics.newFont("assets/Pixel.ttf", 12)
	Text = love.graphics.newText(font, "Hello world")
	Text2 = love.graphics.newText(font, "")
	Text3 = love.graphics.newText(font, "")
	Text:setFont(Font)
	Text2:setFont(Font)
	Text3:setFont(Font)
	timer = 0
	linv = 6
	
	local f = love.filesystem.newFile("saves.txt")
	f:open("r")
	highscore = f:read()
	if type(highscore) == type('10') then
		highscore = tonumber(highscore)
	end
	highscore = highscore or 0
	f:close()

	print('[INFO] LOAD SUCCESSFUL')
end

function love.draw()
	love.graphics.push()
	love.graphics.setShader(myShader)
	myMap:draw()
	if timer > 41 then
		love.graphics.draw(mesh, 0, 0, 0, 640 / texture:getWidth(), 480 / texture:getHeight())
	end
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", -60, 0, 60, 480)
	love.graphics.rectangle("fill", 640, 0, 60, 480)
	love.graphics.setColor(1, 1, 1)
	love.graphics.setShader()
	if gameover then
		love.graphics.print('press C to retry', 0, 0)
	end
	love.graphics.pop()		
	if not(gameover) then
		Text:set(math.floor(timer))
		if pause then 
			Text:set('paused')
		end
		Text3:set(linv)
	else
		Text3:set('')
		Text:set("GAME OVER")
		highscore = highscore or 0
		local score = math.floor(timer)
		if score > highscore then
			print('[INFO] Saving highscore...')
			highscore = score			
			local f = love.filesystem.newFile("saves.txt")
			f:open("w")
			f:write(highscore)
			f:close()
		end
		Text2:set('YOUR SCORE '..score..'\nHIGH SCORE '..highscore)
		love.graphics.draw(Text2, WINDOW_WIDTH/2 - Text2:getWidth()/2, WINDOW_HEIGHT - 100)
	end
	
	if gamestate == 'game' then
		love.graphics.draw(Text, WINDOW_WIDTH/2 - Text:getWidth()/2, 20)
		love.graphics.draw(Text3, math.floor(WINDOW_WIDTH / 2 - Text3:getWidth()/2), WINDOW_HEIGHT - 100)
	elseif gamestate == 'banner' then
		love.graphics.draw(Text2, math.floor(WINDOW_WIDTH/2 - Text2:getWidth()/2), WINDOW_HEIGHT/2 - Text2:getHeight()/2)
	end	
end

function love.update(dt)	
	Input:update()
	if not pause then
		timer = timer + dt
		myMap:update(dt)
		if timer > 40 then
			if not(rain:isPlaying()) then
				rain:play()
			end
			local u, v
			for i=1,4 do
				u, v = mesh:getVertexAttribute(i, 2)
				u, v = u-dt/5, v-dt
				mesh:setVertexAttribute(i, 2, u, v)
			end
		end
		
	else
		if gameover then
			if Input['accept'] then
				myMap:clear()
				start_new()
				pause = false
				gameover = false
				timer = 0
				linv = 6
			end
		end
	end
	
	if gamestate == 'banner' then		
		myMap:update(dt)
		if timer > 1.5 then
			splash.image = TITLE
			if highscore > 60 then 
				Text2:set('SURVIVE '..highscore..' SECONDS')
			else
				Text2:set('SURVIVE 60 SECONDS')
			end
			if Input['accept'] then
				gamestate = 'game'
				start_new()
			end
			if timer > 4 then
				gamestate = 'game'
				start_new()
			end
		end		
	end
end

function love.keyreleased(key)
	if key == "escape" then
		love.event.quit()		
	end
	if key == 'p' then		
		pause = not(pause)
	end
	if key == 'f12' then		
		love.graphics.captureScreenshot('screenshot.png')
	end
	if key == 'f4' or key == 'f11' then
		love.window.setFullscreen(not(love.window.getFullscreen()))
		if love.window.getFullscreen() then 
			WINDOW_WIDTH = love.graphics.getWidth()
			WINDOW_HEIGHT = love.graphics.getHeight()
			myMap.scale = math.min(WINDOW_WIDTH/640, WINDOW_HEIGHT/480)
		else
			WINDOW_WIDTH = love.graphics.getWidth()
			WINDOW_HEIGHT = love.graphics.getHeight()
			myMap.scale = 1 
		end
	end 
end

function inherit(t)
	local t2 = {}
	for k,v in pairs(t) do
		t2[k] = v
	end
	return t2
end

function start_new()
	timer = 0
	testmap = map.new()
	testmap.target = player
	testmap:design({player:at(testmap.width/2, testmap.height/2)})
	myMap = testmap
	myMap:add_bump()
	rain:stop()
end