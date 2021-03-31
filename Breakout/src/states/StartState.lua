--[[
    GD50
    Breakout Remake

    -- StartState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state the game is in when we've just started; should
    simply display "Breakout" in large text, as well as a message to press
    Enter to begin.
]]

-- the "__includes" bit here means we're going to inherit all of the methods
-- that BaseState has, so it will have empty versions of all StateMachine methods
-- even if we don't override them ourselves; handy to avoid superfluous code!
StartState = Class{__includes = BaseState}

-- whether we're highlighting "Start" or "High Scores"
local highlighted = 1

function StartState:enter(params)
    self.paddle_color = params.paddle_color
    self.level = params.start_level
end

function StartState:update(dt)
    -- toggle highlighted option if we press an arrow key up or down
    if love.keyboard.wasPressed('up') then
        all_sounds['select']:play()

        if highlighted == 1 then
            highlighted = 3
        elseif highlighted == 2 then 
            highlighted = 1
        elseif highlighted == 3 then 
            highlighted = 2
        end

        
    elseif love.keyboard.wasPressed('down') then 
        all_sounds['select']:play()

        if highlighted == 1 then
            highlighted = 2
        elseif highlighted == 2 then 
            highlighted = 3
        elseif highlighted == 3 then 
            highlighted = 1
        end

    end

    -- we no longer have this globally, so include here
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    if highlighted == 1 then 
        if love.keyboard.wasPressed('return') or love.keyboard.wasPressed('enter') then
            love.audio.play(all_sounds['confirm'])
            gStateMachine:change('serve', {paddle = Paddle(self.paddle_color),
                                            bricks = LevelMaker.createMap(self.level),
                                            health = 3,
                                            score = 0,
                                            level = self.level
                                            })
        end

    elseif highlighted == 2 then 
        if love.keyboard.wasPressed('return') or love.keyboard.wasPressed('enter') then
            love.audio.play(all_sounds['confirm'])
            gStateMachine:change('paddle_select')
        end
    elseif highlighted == 3 then 
        if love.keyboard.wasPressed('return') or love.keyboard.wasPressed('enter') then
            love.audio.play(all_sounds['confirm'])
            gStateMachine:change('choose_level')
        end
    end
end

function StartState:draw()
    -- title
    love.graphics.setFont(all_fonts['large'])
    love.graphics.printf("WELCOME TO BREAKOUT!", 0, WINDOW_HEIGHT / 3,
        WINDOW_WIDTH, 'center')
    
    love.graphics.setFont(all_fonts['medium'])
    -- if we're highlighting 1, render that option blue
    if highlighted == 1 then
        love.graphics.setColor(255, 0, 0, 255)
    end
    love.graphics.printf("START", 0, WINDOW_HEIGHT*0.6,
        WINDOW_WIDTH, 'center')

    -- reset the color
    love.graphics.setColor(255, 255, 255, 255)

    -- render option 2 blue if we're highlighting that one
    if highlighted == 2 then
        love.graphics.setColor(255, 0, 0, 255)
    end
    love.graphics.printf("SELECT PADDLES SKIN", 0, WINDOW_HEIGHT*0.65,
        WINDOW_WIDTH, 'center')

    -- reset the color
    love.graphics.setColor(255, 255, 255, 255)

    if highlighted == 3 then
        love.graphics.setColor(255, 0, 0, 255)
    end

    love.graphics.printf("CHOOSE STARTING LEVEL", 0, WINDOW_HEIGHT*0.7,
        WINDOW_WIDTH, 'center')

    -- reset the color
    love.graphics.setColor(255, 255, 255, 255)
end