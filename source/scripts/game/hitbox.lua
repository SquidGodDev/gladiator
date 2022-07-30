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

    self.collisionDict = {}

    self.delayTimer = pd.frameTimer.new(delay, function()
        if entity.globalFlip == 1 then
            self.xOffset = -xOffset - w
        end
        self:add()
        pd.frameTimer.new(time, function()
            self:remove()
        end)
    end)
end

function Hitbox:update()
    self:moveTo(self.entity.x + self.xOffset, self.entity.y + self.yOffset)
    local collisions = self:overlappingSprites()
    if #collisions > 0 then
        for i, collisionSprite in ipairs(collisions) do
            local collisionID = collisionSprite._sprite
            if not self.collisionDict[collisionID] then
                self.collisionDict[collisionID] = true
                collisionSprite:damage(self.damage)
                self:signalDamage()
            end
        end
    end
end

function Hitbox:cancel()
    self.delayTimer:remove()
    self:remove()
end

function Hitbox:signalDamage()
    -- Overriden in playerHitbox.lua
end
