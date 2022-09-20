push = require 'push'

Class = require 'class'

require 'Paddle'

require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200


--Used to initialize the game; runs only once
function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    --setting up the title as Pong
    love.window.setTitle('Pong')

    --to make the ball go random everytime
    math.randomseed(os.time())

    -- making font look retro
    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)

    love.graphics.setFont(smallFont)

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })

    --initialzing score
    p1Score = 0
    p2Score = 0

    servingPlayer = 1

    p1 = Paddle(10, 30, 5, 20)
    p2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)
    
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    gameState = 'start'
end

--player1 paddle movement
function love.update(dt)
    if gameState == 'serve' then
        ball.dy = math.random(-50, 50)
        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)
        else
            ball.dx = -math.random(140, 200)
        end
    elseif gameState == 'play' then
        -- detect ball collision with paddles, reversing dx if true and
        -- slightly increasing it, then altering the dy based on the position of collision
        if ball:collides(p1) then
            ball.dx = -ball.dx * 1.03
            ball.x = p1.x + 5

            -- keep velocity going in the same direction, but randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
        end

        if ball:collides(p2) then
            ball.dx = -ball.dx * 1.03
            ball.x = p2.x -4

            -- keep velocity going in the same direction, but randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10,150)
            end
        end

        -- detect upper and lower screen boundary collision and reverse if collided
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
        end

        -- -4 to account for the ball's size
        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
        end
        --updating score for the players
        if ball.x < 0 then
            servingPlayer = 1
            p2Score = p2Score + 1
            if p2Score == 2 then
                winningPlayer = 2
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        end
    
        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            p1Score = p1Score + 1
            if p1Score == 2 then
                winningPlayer = 1
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        end
    end


    --player 1 paddle movement
    if love.keyboard.isDown('w') then
        p1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        p1.dy = PADDLE_SPEED
    else
        p1.dy = 0
    end

    --player2 paddle movement
    if love.keyboard.isDown('up') then
        p2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        p2.dy = PADDLE_SPEED
    else
        p2.dy = 0
    end

    if gameState == 'play' then
        ball:update(dt)
    end

    p1:update(dt)
    p2:update(dt)
end

-- making escape key to close the window
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'done' then
            gameState = 'serve'

            ball:reset()

            p1Score = 0
            p2Score = 0

            --deciding the player who is going to serve the ball
            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    end
end


function love.draw()
    --begin rendering at virtual res
    push:apply ('start')

    love.graphics.clear(40/255, 45/255, 52/255, 255/255)
    
    love.graphics.setFont(smallFont)

    displayScore()
    --drawing welcome text in the game
    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to start!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
    
    elseif gameState == 'done' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' ..tostring(winningPlayer).. ' wins!',
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 40, VIRTUAL_WIDTH, 'center')

    end

    --rendering player movements using their classes
    p1:render()
    p2:render()

    --rendering ball movement using its class
    ball:render()

    displayFPS()

    push:apply ('end')
end

function displayFPS()
    -- simple FPS display across all states
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255/255, 0, 255/255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

function displayScore()
    -- draw score on the left and right center of the screen
    -- need to switch font to draw before actually printing
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(p1Score), VIRTUAL_WIDTH / 2 - 50, 
        VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(p2Score), VIRTUAL_WIDTH / 2 + 30,
        VIRTUAL_HEIGHT / 3)
end