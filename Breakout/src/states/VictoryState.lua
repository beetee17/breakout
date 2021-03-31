VictoryState = Class{__includes = BaseState}

function VictoryState:enter(params)
	self.paddle = params.paddle
	self.ball = params.ball
	self.bricks = params.bricks
	self.health = params.health
	self.score = params.score
	self.level = params.level
end

function VictoryState:update(dt)
	if love.keyboard.wasPressed('return') or love.keyboard.wasPressed('enter') then 
		gStateMachine:change('serve', {paddle = self.paddle,
										ball = self.ball,
										bricks = self.bricks,
										health = self.health,
										score = self.score,
										level = self.level
										})
	end

	if love.keyboard.wasPressed('escape') then 
		love.event.quit()
	end
end

function VictoryState:draw()

	love.graphics.setFont(all_fonts['large'])

    love.graphics.printf('LEVEL '..tostring(self.level - 1)..' COMPLETE!', 0, WINDOW_HEIGHT / 3, WINDOW_WIDTH, 'center')

    love.graphics.setFont(all_fonts['medium'])

    love.graphics.printf('Press Enter to Continue!', 0, WINDOW_HEIGHT*0.55,
        WINDOW_WIDTH, 'center')
end