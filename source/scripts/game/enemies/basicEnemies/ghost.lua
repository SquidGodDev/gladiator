import "scripts/game/enemies/basicEnemies/basicEnemy"
import "scripts/game/enemies/enemyHitbox"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Ghost').extends(BasicEnemy)

function Ghost:init(x)
    local ghostSpriteSheet = gfx.imagetable.new("images/enemies/ghost/ghost-table-32-32")
    Ghost.super.init(self, x, ghostSpriteSheet)

    self.health = 40

    self:addState("idle", 1, 12, {tickStep = 4})
    self:addState("run", 13, 18, {tickStep = 4})
    self:addState("attack", 26, 31, {tickStep = 3, nextAnimation = "idle"})
    self.states["attack"].onStateChangedEvent = function()
        self:createAttackHitbox()
    end
    self:addState("hit", 19, 19)
    self:addState("death", 19, 25, {tickStep = 5, loop = false})
    self.states["death"].onAnimationEndEvent = function()
        self:remove()
    end

    self.idleCollisionRect = pd.geometry.rect.new(4, 4, 25, 28)
    self.runCollisionRect = pd.geometry.rect.new(4, 4, 25, 28)
    self.attackCollisionRect = pd.geometry.rect.new(4, 4, 25, 28)

    self.attackDamage = 3

    self.maxSpeed = 2
    self.startVelocity = 1
    self.acceleration = 0.3
    self.friction = 0.1

    self.paceTime = 1000

    self.detectRange = 150
    self.attackRange = 20
    self.attackCooldown = 1000

    self.hitStunTime = 500
    self.hitVelocity = 4

    self.getsStunned = false

    self:playAnimation()
end

function Ghost:createAttackHitbox()
    local xOffset, yOffset = -15, -30
    local width, height = 23, 30
    local delay, time = 4, 2
    self.attackHitbox = EnemyHitbox(self, xOffset, yOffset, width, height, delay, time, self.attackDamage)
end