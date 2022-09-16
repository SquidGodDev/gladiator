-- How I create hitboxes in the game. I found it the most intuitive to create a system where I get the entity
-- that is creating the hitbox, and then spawn the hitbox from some offset of the entity. This way, if the
-- entity moves while the hitbox is active, the hitbox will move with the entity (e.g. moving while spin attacking)
-- I've also added delay and time arguments, because I spawn the hitbox at the start of a move, but most times, the
-- hitbox shouldn't appear until the actual animation looks like it should hit, and the hitbox should be active based
-- on how fast the animation is. 

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
    -- Moving the hitbox based on if the entity has moved to make sure the hitbox follows
    self:moveTo(self.entity.x + self.xOffset, self.entity.y + self.yOffset)
    local collisions = self:overlappingSprites()
    if #collisions > 0 then
        for i, collisionSprite in ipairs(collisions) do
            -- I save the collision ID of whatever I hit, to make sure things don't get hit again
            -- if they've already been hit by a hitbox. If you don't do this, then either things will
            -- get hit multiple times by one attack, or if you disable a hitbox after hitting something,
            -- you can't hit multiple enemies at once
            local collisionID = collisionSprite._sprite
            if not self.collisionDict[collisionID] then
                self.collisionDict[collisionID] = true
                local isAlive = collisionSprite:damage(self.damage)
                if isAlive then
                    self:signalDamage()
                end
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
