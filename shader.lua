--shaders
shader = {}

function shader.getCode()
	local code
	code = love.filesystem.read('shaders/default.frag')
	return code
end