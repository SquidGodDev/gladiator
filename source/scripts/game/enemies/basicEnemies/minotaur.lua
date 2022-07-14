import "scripts/game/enemies/basicEnemies/basicEnemy"
import "scripts/game/enemies/enemyHitbox"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Minotaur').extends(BasicEnemy)

function Minotaur:init(x)
    local minotaurSpriteSheet = gfx.imagetable.new("images/enemies/minotaur/minotaur-table-144-80")
    Minotaur.super.init(self, x, minotaurSpriteSheet)

    self.health = 100

    self:addState("idle", 1, 8, {tickStep = 4})
    self:addState("run", 9, 16, {tickStep = 4})
    self:addState("attack", 17, 32, {tickStep = 3, nextAnimation = "idle"})
    self.states["attack"].onStateChangedEvent = function()
        self:createAttackHitbox()
    end
    self:addState("hit", 33, 33)
    self:addState("death", 33, 43, {tickStep = 4, loop = false})
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

    self.idleCollisionRect = pd.geometry.rect.new(50, 35, 44, 45)
    self.runCollisionRect = pd.geometry.rect.new(50, 35, 44, 45)
    self.attackCollisionRect = pd.geometry.rect.new(50, 35, 44, 45)

    self.attackDamage = 10

    self.maxSpeed = 1
    self.startVelocity = 0.5
    self.acceleration = 0.3
    self.friction = 0.3

    self.paceTime = 2000

    self.detectRange = 150
    self.attackRange = 40
    self.attackCooldown = 1500

    self.hitStunTime = 500
    self.hitVelocity = 0

    self.getsStunned = false

    self:playAnimation()
end

function Minotaur:createAttackHitbox()
    local xOffset, yOffset = 14, -60
    local width, height = 49, 60
    local delay, time = 24, 4
    self.attackHitbox = EnemyHitbox(self, xOffset, yOffset, width, height, delay, time, self.attackDamage)
end