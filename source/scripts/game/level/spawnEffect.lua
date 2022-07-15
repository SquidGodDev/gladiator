local pd <const> = playdate
local gfx <const> = pd.graphics

class('SpawnEffect').extends(gfx.sprite)

function SpawnEffect:init(x, enemy)
    self.columnWidth = 30
    self.borderWidth = 1
    local part1 = pd.timer.new(200, 0, GROUND_LEVEL, pd.easingFunctions.inOutExpo)
    part1.updateCallback = function(timer)
        local columnImage = gfx.image.new(self.columnWidth + self.borderWidth * 2, GROUND_LEVEL)
        gfx.pushContext(columnImage)
            gfx.setColor(gfx.kColorBlack)
            gfx.fillRect(0, 0, self.columnWidth + self.borderWidth * 2, timer.value)
            gfx.setColor(gfx.kColorWhite)
            gfx.fillRect(self.borderWidth, 0, self.columnWidth, timer.value)
        gfx.popContext()
        self:setImage(columnImage)
    end
    part1.timerEndedCallback = function()
        enemy(x)
        local part2 = pd.timer.new(300, self.columnWidth, 0, pd.easingFunctions.inOutExpo)
        part2.updateCallback = function(timer)
            local columnImage = gfx.image.new(self.columnWidth + self.borderWidth * 2, GROUND_LEVEL)
            gfx.pushContext(columnImage)
                gfx.setColor(gfx.kColorBlack)
                gfx.fillRect(self.columnWidth / 2 - timer.value / 2, 0, timer.value + self.borderWidth * 2, GROUND_LEVEL)
                gfx.setColor(gfx.kColorWhite)
                gfx.fillRect(self.borderWidth + self.columnWidth / 2 - timer.value / 2, 0, timer.value, GROUND_LEVEL)
            gfx.popContext()
            self:setImage(columnImage)
        end
        part2.timerEndedCallback = function()
            self:remove()
        end
    end
    self:setZIndex(100)
    self:setCenter(.5, 0)
    self:moveTo(x, 0)
    self:add()
end