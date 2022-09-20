Ball = Class{}

--initializing the ball
function Ball:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    self.dy = math.random(2) == 1 and -100 or 100
    self.dx = math.random(2) == 1 and math.random(-80,-100) or math.random(80, 100)
end

--adding collision of ball with the paddle
function Ball:collides(paddle)
    --checking for left and right
    if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then
        return false
    end
    
    --checking for bottom and top
    if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then
        return false
    end 

    return true
end

--resetting the position of the ball
function Ball:reset()
    self.x = VIRTUAL_WIDTH / 2 - 2
    self.y = VIRTUAL_HEIGHT / 2 - 2
    self.dx = math.random(2) == 1 and -100 or 100
    self.dy = math.random(-50, 50)
end


--movement speed of the ball
function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

--rendering the ball
function Ball:render()
    -- love.graphics.setColor(1, .6, .6)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end