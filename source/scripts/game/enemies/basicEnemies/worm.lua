import "scripts/game/enemies/basicEnemies/basicEnemy"
import "scripts/game/enemies/enemyHitbox"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Worm').extends(BasicEnemy)

function Worm:init(x)
    local wormSpriteSheet = gfx.imagetable.new("images/enemies/worm/worm-table-48-48")
    Worm.super.init(self, x, wormSpriteSheet)

    self.health = 20

    self:addState("idle", 1, 6, {tickStep = 4})
    self:addState("run", 7, 12, {tickStep = 4})
    self:addState("attack", 20, 25, {tickStep = 3, nextAnimation = "idle"})
    self.states["attack"].onStateChangedEvent = function()
        self:createAttackHitbox()
    end
    self:addState("hit", 13, 13)
    self:addState("death", 13, 19, {tickStep = 4, loop = false})
    self.states["death"].onAnimationEndEvent = function()
        self:remove()
    end

    self.idleCollisionRect = pd.geometry.rect.new(6, 30, 36, 18)
    self.runCollisionRect = pd.geometry.rect.new(6, 30, 36, 18)
    self.attackCollisionRect = pd.geometry.rect.new(6, 30, 36, 18)

    self.attackDamage = 2

    self.maxSpeed = 2
    self.startVelocity = 1
    self.acceleration = 0.3
    self.friction = 0.3

    self.paceTime = 1000

    self.detectRange = 100
    self.attackRange = 40
    self.attackCooldown = 700

    self.hitStunTime = 500
    self.hitVelocity = 2

    self.getsStunned = true

    self:playAnimation()
end

function Worm:createAttackHitbox()
    local xOffset, yOffset = 10, -14
    local width, height = 16, 12
    local delay, time = 6, 2
    self.attackHitbox = EnemyHitbox(self, xOffset, yOffset, width, height, delay, time, self.attackDamage)
end