local Class = require "libs.hump.class"
local Timer = require "libs.hump.timer"
local Tween = require "libs.tween" 

local statFont = love.graphics.newFont(26)

local Stats = Class{}


function Stats:init(sounds)
    self.y = 10 -- we will need it for tweening later
    self.level = 1 -- current level    
    self.totalScore = 0 -- total score so far
    self.targetScore = 1000
    self.maxSecs = 99 -- max seconds for the level
    self.elapsedSecs = 0 -- elapsed seconds
    self.timeOut = false -- when time is out
    self.tweenLevel = nil -- for later
    self.sounds = sounds -- Added to stop error when game ends
end

-- Wanted to do a visual overhual to make the game look cleaner
function Stats:draw()
    love.graphics.setColor(1, 0, 1) 
    love.graphics.printf("Level " .. tostring(self.level), statFont, gameWidth / 2 - 60, self.y, 100, "center")
    local timeLeft = math.max(0, self.maxSecs - math.floor(self.elapsedSecs))
    if timeLeft <= 10 then
        -- Red meaning time is running out
        love.graphics.setColor(1, 0.2, 0.2) 
    else
        love.graphics.setColor(1, 0, 1) 
    end
    -- Make number formaat way cleaner
    -- https://stackoverflow.com/questions/12466950/lua-program-shows-current-time for time formating
    love.graphics.printf(string.format("Time: %02d / %02d", timeLeft, self.maxSecs), statFont, 10, 10, 200)
    love.graphics.setColor(1, 0, 1) 
    love.graphics.printf("Score: " .. tostring(self.totalScore), statFont, gameWidth - 210, 10, 200, "right")
    love.graphics.setColor(1, 1, 1)
end

function Stats:update(dt)
    if gameState == "play" then
        self.elapsedSecs = self.elapsedSecs + dt
        if self.elapsedSecs >= self.maxSecs then
            self.timeOut = true
            if self.sounds and self.sounds["timeOut"] then
                self.sounds["timeOut"]:play()
            end
            gameState = "over"
        end
    end
    self.tween = self.tween and (not self.tween:update(dt) and self.tween or nil)
end



function Stats:addScore(n)
    self.totalScore = self.totalScore + n
    if self.totalScore > self.targetScore then
        self:levelUp()
    end
end

function Stats:levelUp()
    self.level = self.level +1
    self.targetScore = self.targetScore+self.level*1000
    self.elapsedSecs = 0
    -- Sound efect to make it noticeable 
    if self.sounds and self.sounds["levelUp"] then
        self.sounds["levelUp"]:play()
    end    
    self.y = 10
    self.tween = Tween.new(0.5, self, { y = 40 }, 'outBounce')
end

    
return Stats
    