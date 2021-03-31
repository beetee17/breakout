PlayState = Class{__includes = BaseState}


function PlayState:enter(params)
	self.paddle = params.paddle
	self.ball = params.ball
	self.bricks = params.bricks
	self.health = params.health
	self.score = params.score

	self.paused = false
	self.level = params.level
end

function PlayState:update(dt)

	-- if self.paused then 
	-- 	if love.keyboard.wasPressed('space') then 
	-- 		self.paused = false
	-- 	end

	-- else
	-- 	if love.keyboard.wasPressed('space') then 
	-- 		self.paused = true
	-- 		love.audio.play(all_sounds['pause']) 
			
	-- 	end
	-- end

	self.paddle:update(dt)
	self.ball:update(dt)


	if self.ball.y > WINDOW_HEIGHT then 
		self.health = self.health - 1
		love.audio.play(all_sounds['hurt'])

		if self.health == 0 then 
			gStateMachine:change('game_over', {score = self.score})
		else
			gStateMachine:change('serve', {paddle = self.paddle,
	                                            bricks = self.bricks,
	                                            health = self.health,
	                                            score = self.score,
	                                            level = self.level
	                                            })
		end
	end

	if self.paddle.has_collided then 
		if self.ball.x + self.ball.width < self.paddle.x - self.paddle.width*1.1 or 
			self.ball.x > self.paddle.x + self.paddle.width*1.1 or 
			self.ball.y + self.ball.height < self.paddle.y - self.paddle.height*1.1 or 
			self.ball.y > self.paddle.y + self.paddle.height*1.1 then 

			self.paddle.has_collided = false 
		end
	end

	if self.ball:is_collided_with(self.paddle) and not self.paddle.has_collided then 
		
		self.paddle.has_collided = true 
		self.ball.dy = - self.ball.dy 

		if self.ball.y + self.ball.height < self.paddle.y + self.paddle.height*0.85 then
			self.ball.y = self.paddle.y - self.ball.height
		end

		 -- if we hit the paddle on its left side while moving left...
        if self.ball.x < self.paddle.x + (self.paddle.width / 2) then
        	if self.paddle.dx < 0 then 
            	self.ball.dx = 0.2*self.paddle.dx - (5*math.abs(self.paddle.x + self.paddle.width / 2 - self.ball.x))
            elseif self.paddle.dx == 0 and self.ball.x + self.ball.width < self.paddle.x + self.paddle.width*0.05 then 
            	self.ball.dx = math.min(-self.ball.dx*0.9, -2*(math.abs(self.paddle.x + self.paddle.width / 2 - self.ball.x)))
            end

            if self.ball.x + self.ball.width < self.paddle.x - self.paddle.width*0.02 then 
            	self.ball.x = self.paddle.x - self.ball.width - 1
            else 
            	self.ball.y = self.paddle.y - self.ball.height
            end
        
            -- else if we hit the paddle on its right side while moving right...
        elseif self.ball.x > self.paddle.x + (self.paddle.width / 2) then

            if self.paddle.dx > 0 then 
            	self.ball.dx = 0.2*self.paddle.dx + (5*math.abs(self.paddle.x + self.paddle.width / 2 - self.ball.x))
            elseif self.paddle.dx == 0 and self.ball.x > self.paddle.x + self.paddle.width*0.95 then 
            	self.ball.dx = math.max(-self.ball.dx*0.9, 2*(math.abs(self.paddle.x + self.paddle.width / 2 - self.ball.x)))
            end

            if self.ball.x > self.paddle.x + self.paddle.width*0.98 then 
            	self.ball.x = self.paddle.x + self.paddle.width + 1
            else 
            	self.ball.y = self.paddle.y - self.ball.height
            end
        end


		love.audio.play(all_sounds['paddle-hit'])
	end


	bricks_in_play = 0

	for index, brick in pairs(self.bricks) do 
		if brick.inPlay then 
			bricks_in_play = bricks_in_play + 1
		end
	end

	if bricks_in_play == 0 then 
		self.level = self.level + 1
		love.audio.play(all_sounds['victory'])
		gStateMachine:change('victory', {paddle = self.paddle,
										health = math.min(self.health + 1, 3),
										ball = self.ball,
										bricks = LevelMaker.createMap(self.level),
										score = self.score,
										level = self.level
										})
	end

	for index, brick in pairs(self.bricks) do 
		if self.ball:is_collided_with(brick) and brick.inPlay then
			brick:hit()
			self.score = self.score + (brick.tier*200 + brick.color*25)
	

			--
	        -- collision code for bricks
	        --
	        -- we check to see if the opposite side of our velocity is outside of the brick;
	        -- if it is, we trigger a collision on that side. else we're within the X + width of
	        -- the brick and should check to see if the top or bottom edge is outside of the brick,
	        -- colliding on the top or bottom accordingly 
	        --

	        -- left edge; only check if we're moving right, and offset the check by a couple of pixels
	        -- so that flush corner hits register as Y flips, not X flips
	     	if self.ball.dx > 0 and self.ball.x + 2 < brick.x then 
	            
	            -- flip x velocity and reset position outside of brick
	            self.ball.dx = - self.ball.dx
	            self.ball.x = brick.x - self.ball.width
	        
	        -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
	        -- so that flush corner hits register as Y flips, not X flips
	        elseif self.ball.dx < 0 and self.ball.x + 6 > brick.x + brick.width then 

	            -- flip x velocity and reset position outside of brick
	    		self.ball.dx = - self.ball.dx
	            self.ball.x = brick.x + brick.width 
	        
	        -- top edge if no X collisions, always check
	 		elseif self.ball.y < brick.y then 
	            
	            -- flip y velocity and reset position outside of brick
	            self.ball.dy = - self.ball.dy 
	            self.ball.y = brick.y - self.ball.height 
	        
	        -- bottom edge if no X collisions or top collision, last possibility
	        else
	            
	            -- flip y velocity and reset position outside of brick
	            self.ball.dy = - self.ball.dy 
	            self.ball.y = brick.y + brick.height 
	        end

	        -- slightly scale the y velocity to speed up the game
	        self.ball.dy = self.ball.dy * 1.02

	        -- only allow colliding with one brick, for corners
	        break
		end
	end
	


	if love.keyboard.wasPressed('escape') then 
		love.event.quit()
	end

end


function PlayState:draw()
	self.paddle:draw()
	self.ball:draw()
	drawHealth(self.health)
	drawScore(self.score)
	love.graphics.setFont(all_fonts['small'])
	love.graphics.printf('Level: '..tostring(self.level), 
								0, 
								WINDOW_HEIGHT*0.01, 
								WINDOW_WIDTH, 
								'center')

	for index, brick in pairs(self.bricks) do 
		brick:draw()
		if self.ball:is_collided_with(brick) and brick.inPlay then
			brick:renderParticles()
		end
	end

	if self.paused then 
		love.graphics.setFont(all_fonts['large'])
		love.graphics.printf('PAUSED', 
									0, 
									0, 
									WINDOW_WIDTH, 
									'center')
	end

end