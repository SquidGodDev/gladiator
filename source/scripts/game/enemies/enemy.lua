import "scripts/libraries/AnimatedSprite"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Enemy').extends(AnimatedSprite)

function Enemy:init(x, spritesheet)
    Enemy.super.init(self, spritesheet)
    self:setGroups(ENEMY_GROUP)
    self.collisionResponse = gfx.sprite.kCollisionTypeOverlap
    self:setCenter(0.5, 1.0)
    self:moveTo(x, GROUND_LEVEL)
    self.hitFlashTime = 100
    self.died = false
end

function Enemy:damage(amount)
    self.health -= amount
    self:setImageDrawMode(gfx.kDrawModeFillWhite)
    pd.timer.new(self.hitFlashTime, function()
        self:setImageDrawMode(gfx.kDrawModeCopy)
    end)
end
