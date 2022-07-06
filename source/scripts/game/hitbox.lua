local pd <const> = playdate
local gfx <const> = pd.graphics

class('Hitbox').extends(gfx.sprite)

function Hitbox:init(entity, xOffset, yOffset, w, h, delay, time, damage)
    self.damage = damage
    self:setCenter(0, 0)
    self.entity = entity
    self.xOffset = xOffset
    self.yOffset = yOffset
    self:moveTo(entity.x + xOffset, entity.y + yOffset)
    self:setCollideRect(0, 0, w, h)
    self.collisionResponse = gfx.sprite.kCollisionTypeOverlap

    pd.frameTimer.new(delay, function()
        self:add()
        pd.frameTimer.new(time, function()
            self:remove()
        end)
    end)
end

function Hitbox:update()
    self:moveTo(self.entity.x + self.xOffset, self.entity.y + self.yOffset)
    local collisions = self:overlappingSprites()
end