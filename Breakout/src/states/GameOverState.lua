GameOverState = Class{__includes = BaseState}

function GameOverState:enter(params)
	self.score = params.score 
end

function GameOverState:update(dt)
	if love.keyboard.wasPressed('return') or love.keyboard.wasPressed('enter') then 
		gStateMachine:change('start', {paddle_color = 1,
                                        start_level = 1}) 
	end

	if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end


function GameOverState:draw()
    love.graphics.setFont(all_fonts['large'])

    love.graphics.printf('GAME OVER', 0, WINDOW_HEIGHT / 3, WINDOW_WIDTH, 'center')

    love.graphics.setFont(all_fonts['medium'])

    love.graphics.printf('Final Score: ' .. tostring(self.score), 0, WINDOW_HEIGHT*0.45,
        WINDOW_WIDTH, 'center')

    love.graphics.printf('Press Enter to Continue!', 0, WINDOW_HEIGHT*0.55,
        WINDOW_WIDTH, 'center')
end