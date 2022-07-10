import "scripts/game/enemies/basicEnemy"
import "scripts/game/enemies/enemyHitbox"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Wolf').extends(BasicEnemy)

function Wolf:init(x)
    local wolfSpriteSheet = gfx.imagetable.new("images/enemies/wolf/wolf-table-64-48")
    Wolf.super.init(self, x, wolfSpriteSheet)

    self.health = 25

    self:addState("idle", 1, 8, {tickStep = 4})
    self:addState("run", 9, 14, {tickStep = 4})
    self:addState("attack", 21, 26, {tickStep = 3, nextAnimation = "idle"})
    self.states["attack"].onStateChangedEvent = function()
        self:createAttackHitbox()
    end
    self:addState("hit", 15, 15)
    self:addState("death", 15, 20, {tickStep = 5, loop = false})
    self.states["death"].onAnimationEndEvent = function()
        self.died = true
        self.deathImage = self:getImage()
        local deathFadeTimer = pd.timer.new(1000, 1.0, 0.0)
        deathFadeTimer.updateCallback = function(timer)
            local fadedImage = self.deathImage:fadedImage(timer.value, gfx.image.kDitherTypeBayer8x8)
            local flipped = gfx.kImageUnflipped
            if self.globalFlip == 1 then
                flipped = gfx.kImageFlippedX
            end
            self:setImage(fadedImage, flipped)
        end
        deathFadeTimer.timerEndedCallback = function()
            self:remove()
        end
    end

    self.idleCollisionRect = pd.geometry.rect.new(11, 21, 38, 27)
    self.runCollisionRect = pd.geometry.rect.new(11, 21, 38, 27)
    self.attackCollisionRect = pd.geometry.rect.new(11, 21, 38, 27)

    self.attackDamage = 5

    self.maxSpeed = 4
    self.startVelocity = 2
    self.acceleration = 0.3
    self.friction = 0.3

    self.paceTime = 1000

    self.detectRange = 100
    self.attackRange = 30
    self.attackCooldown = 1000

    self.hitStunTime = 500
    self.hitVelocity = 3

    self:playAnimation()
end

function Wolf:createAttackHitbox()
    local xOffset, yOffset = 2, -22
    local width, height = 28, 18
    local delay, time = 4, 2
    if self.globalFlip == 1 then
        xOffset = -xOffset - width
    end
    self.attackHitbox = EnemyHitbox(self, xOffset, yOffset, width, height, delay, time, self.attackDamage)
end