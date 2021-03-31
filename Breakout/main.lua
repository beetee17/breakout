require 'src/Dependencies'

function love.load()
    min_dt = 1/max_FPS
    next_time = love.timer.getTime()

    math.randomseed(os.time())

    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = false
        })

    love.window.setTitle('Breakout')
    love.keyboard.keysPressed = {}

    all_fonts = {
    ['small'] = love.graphics.newFont('fonts/font.ttf', WINDOW_WIDTH/67.5),
    ['medium'] = love.graphics.newFont('fonts/font.ttf', WINDOW_WIDTH/33.75),
    ['large'] = love.graphics.newFont('fonts/font.ttf', WINDOW_WIDTH/16.875),
}

    all_textures = {

    ['background'] = love.graphics.newImage('graphics/background.png'),
    ['main'] = love.graphics.newImage('graphics/breakout.png'),
    ['blocks'] = love.graphics.newImage('graphics/blocks.png'),
    ['arrows'] = love.graphics.newImage('graphics/arrows.png'),
    ['hearts'] = love.graphics.newImage('graphics/hearts.png'),
    ['particle'] = love.graphics.newImage('graphics/particle.png')
}
    
    all_sounds = {

    ['paddle-hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
    ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
    ['wall-hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
    ['confirm'] = love.audio.newSource('sounds/confirm.wav', 'static'),
    ['select'] = love.audio.newSource('sounds/select.wav', 'static'),
    ['no-select'] = love.audio.newSource('sounds/no-select.wav', 'static'),
    ['brick-hit-1'] = love.audio.newSource('sounds/brick-hit-1.wav', 'static'),
    ['brick-hit-2'] = love.audio.newSource('sounds/brick-hit-2.wav', 'static'),
    ['hurt'] = love.audio.newSource('sounds/hurt.wav', 'static'),
    ['victory'] = love.audio.newSource('sounds/victory.wav', 'static'),
    ['recover'] = love.audio.newSource('sounds/recover.wav', 'static'),
    ['high-score'] = love.audio.newSource('sounds/high_score.wav', 'static'),
    ['pause'] = love.audio.newSource('sounds/pause.wav', 'static'),

    ['music_1'] = love.audio.newSource('sounds/music.wav', 'static'),
    ['music_2'] = love.audio.newSource( '/sounds/BG_Music.wav', 'static' )

}

    all_frames = {
    ['paddles'] = GenerateQuadPaddles(all_textures['main']),
    ['balls'] = GenerateQuadBalls(all_textures['main']),
    ['bricks'] = GenerateQuadBricks(all_textures['main']),
    ['hearts'] = GenerateQuadHealths(all_textures['main']),
    ['arrows'] = GenerateQuadArrows(all_textures['arrows'])
}


    -- the state machine we'll be using to transition between various states
    -- in our game instead of clumping them together in our update and draw
    -- methods
    --
    -- our current game state can be any of the following:
    -- 1. 'start' (the beginning of the game, where we're told to press Enter)
    -- 2. 'paddle-select' (where we get to choose the color of our paddle)
    -- 3. 'serve' (waiting on a key press to serve the ball)
    -- 4. 'play' (the ball is in play, bouncing between paddles)
    -- 5. 'victory' (the current level is over, with a victory jingle)
    -- 6. 'game-over' (the player has lost; display score and allow restart)
    gStateMachine = StateMachine {
        ['start'] = function() return StartState() end,
        ['play'] = function() return PlayState() end,
        ['serve'] = function() return ServeState() end,
        ['game_over'] = function() return GameOverState() end,
        ['victory'] = function() return VictoryState() end,
        ['paddle_select']  = function() return PaddleSelectState() end,
        ['choose_level'] = function() return ChooseLevelState() end
    }
    gStateMachine:change('start', {paddle_color = 1,
                                    start_level = 1})

    all_sounds['music_2']:setLooping(true)
    all_sounds['music_2']:setVolume(0.2)
    all_sounds['music_2']:play()

    -- a table we'll use to keep track of which keys have been pressed this
    -- frame, to get around the fact that LÖVE's default callback won't let us
    -- test for input from within other functions
    love.keyboard.keysPressed = {}

end

function love.update(dt)

    -- pass in dt to the state object we're currently using
    gStateMachine:update(dt)


    love.keyboard.keysPressed = {}

    next_time = next_time + min_dt

end



function love.draw()
    love.graphics.setColor(0, 255, 255, 255)
    love.graphics.draw(all_textures['background'],
                        0,
                        0,
                        0,
                        WINDOW_WIDTH/(all_textures['background']:getWidth() - 1),
                        WINDOW_HEIGHT/(all_textures['background']:getHeight() - 1)
                        )
    love.graphics.setColor(255, 255, 255, 255)



    -- use the state machine to defer rendering to the current state we're in
    gStateMachine:draw()

    displayFPS()

    local cur_time = love.timer.getTime()
        if next_time <= cur_time then
          next_time = cur_time
          return
        end

    love.timer.sleep(next_time - cur_time)


end





function love.keypressed(key)
    love.keyboard.keysPressed[key] = true
end


--[[
    A custom function that will let us test for individual keystrokes outside
    of the default `love.keypressed` callback, since we can't call that logic
    elsewhere by default.
]]
function love.keyboard.wasPressed(key)
    if love.keyboard.keysPressed[key] then 
        return true
    else
        return false
    end
end


function displayFPS()
    -- simple FPS display across all states
    love.graphics.setFont(all_fonts['small'])
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 5, 5)
    love.graphics.setColor(255, 255, 255, 255)
end

function drawHealth(health)
    -- start of our health rendering
    local healthX = WINDOW_WIDTH*0.1
    local scale = WINDOW_WIDTH/308
    
    -- render health left
    for i = 1, health do
        love.graphics.draw(all_textures['main'], all_frames['hearts'][1], healthX,  WINDOW_HEIGHT*0.01, 0, scale, scale)
        healthX = healthX + 11*(scale)
    end

    -- render missing health
    for i = 1, 3 - health do
        love.graphics.draw(all_textures['main'], all_frames['hearts'][2], healthX,  WINDOW_HEIGHT*0.01, 0, scale, scale)
        healthX = healthX + 11*scale
    end
end

function drawScore(score)
    love.graphics.setFont(all_fonts['medium'])
    love.graphics.print('Score: '..tostring(score), WINDOW_WIDTH*0.8, WINDOW_HEIGHT*0.01)
end

function love.resize(w, h)
    WINDOW_WIDTH = w
    WINDOW_HEIGHT = h
    all_fonts = {
    ['small'] = love.graphics.newFont('fonts/font.ttf', WINDOW_WIDTH/67.5),
    ['medium'] = love.graphics.newFont('fonts/font.ttf', WINDOW_WIDTH/33.75),
    ['large'] = love.graphics.newFont('fonts/font.ttf', WINDOW_WIDTH/16.875),
}
    gStateMachine:update(dt)
    gStateMachine:draw()

end
