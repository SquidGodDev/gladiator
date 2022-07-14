import "scripts/game/enemies/basicEnemies/basicEnemy"
import "scripts/game/enemies/enemyHitbox"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Rat').extends(BasicEnemy)

function Rat:init(x)
    local ratSpriteSheet = gfx.imagetable.new("images/enemies/rat/rat-table-48-48")
    Rat.super.init(self, x, ratSpriteSheet)

    self.health = 15

    self:addState("idle", 1, 8, {tickStep = 4})
    self:addState("run", 9, 14, {tickStep = 4})
    self:addState("attack", 21, 26, {tickStep = 3, nextAnimation = "idle"})
    self.states["attack"].onStateChangedEvent = function()
        self:createAttackHitbox()
    end
    self:addState("hit", 15, 15)
    self:addState("death", 15, 19, {tickStep = 5, loop = false})
    self.states["death"].onAnimationEndEvent = function()
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

    self.idleCollisionRect = pd.geometry.rect.new(3, 31, 40, 17)
    self.runCollisionRect = pd.geometry.rect.new(3, 31, 40, 17)
    self.attackCollisionRect = pd.geometry.rect.new(3, 31, 40, 17)

    self.attackDamage = 3

    self.maxSpeed = 3
    self.startVelocity = 1
    self.acceleration = 0.3
    self.friction = 0.3

    self.paceTime = 1000

    self.detectRange = 100
    self.attackRange = 30
    self.attackCooldown = 1000

    self.hitStunTime = 500
    self.hitVelocity = 3

    self.getsStunned = true

    self:playAnimation()
end

function Rat:createAttackHitbox()
    local xOffset, yOffset = 2, -15
    local width, height = 18, 10
    local delay, time = 4, 2
    self.attackHitbox = EnemyHitbox(self, xOffset, yOffset, width, height, delay, time, self.attackDamage)
end