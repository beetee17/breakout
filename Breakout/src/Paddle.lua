Paddle = Class{}

function Paddle:init(color)
	self.width = 64*(WINDOW_WIDTH/420)
	self.height = 16*(WINDOW_HEIGHT/400)
	self.x = WINDOW_WIDTH/2 - self.width/2
	self.y = WINDOW_HEIGHT*0.9
	self.dx = 0
	self.color = color
	self.size = 2
	self.has_collided = false
	
	self.centerx = self.x + (self.width / 2)
end


function Paddle:update(dt)
	if love.keyboard.isDown('left') then
		self.dx = -PADDLE_SPEED
	elseif love.keyboard.isDown('right') then 
		self.dx = PADDLE_SPEED
	else
		self.dx = 0
	end

	-- boundary detection/handling
	if self.dx < 0 then 
		self.x = math.max(0, self.x + self.dx*dt)
	else
		self.x = math.min(WINDOW_WIDTH - self.width, self.x + self.dx*dt)
	end


end

function Paddle:draw()
	love.graphics.draw(all_textures['main'], 
						all_frames['paddles'][self.size + 4*(self.color - 1)], 
						self.x, 
						self.y,
						0,
						WINDOW_WIDTH/420,
						WINDOW_HEIGHT/400)
end
