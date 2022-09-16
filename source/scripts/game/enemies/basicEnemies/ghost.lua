-- I'll use the ghost as an example of how I extend the basicEnemy class. As you can see, you
-- need to initialize a lot of things, but it's pretty straightforward.

import "scripts/game/enemies/basicEnemies/basicEnemy"
import "scripts/game/enemies/enemyHitbox"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Ghost').extends(BasicEnemy)

function Ghost:init(x)
    local ghostSpriteSheet = gfx.imagetable.new("images/enemies/ghost/ghost-table-32-32")
    Ghost.super.init(self, x, ghostSpriteSheet)

    -- Initializing the health
    self.health = 40

    -- Here, I create the states
    -- that match the ghosts animation spritesheet, since each enemy has different animations that take
    -- a different amount of time.
    self:addState("idle", 1, 12, {tickStep = 4})
    self:addState("run", 13, 18, {tickStep = 4})
    self:addState("attack", 26, 31, {tickStep = 3, nextAnimation = "idle"})
    -- An attack is not explicity defined in the basicEnemy class, so we create the attack hitbox here
    self.states["attack"].onStateChangedEvent = function()
        self:createAttackHitbox()
    end
    self:addState("hit", 19, 19)
    self:addState("death", 19, 25, {tickStep = 5, loop = false})
    self.states["death"].onAnimationEndEvent = function()
        self:remove()
    end

    -- These are the hitboxes for the enemy, which gets used in basicEnemy
    self.idleCollisionRect = pd.geometry.rect.new(4, 4, 25, 28)
    self.runCollisionRect = pd.geometry.rect.new(4, 4, 25, 28)
    self.attackCollisionRect = pd.geometry.rect.new(4, 4, 25, 28)

    -- Setting a bunch of adjustable parameters on the enemy
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

-- Using the hitbox class I've created, I can make custom sized hitboxes
function Ghost:createAttackHitbox()
    local xOffset, yOffset = -15, -30
    local width, height = 23, 30
    local delay, time = 4, 2
    self.attackHitbox = EnemyHitbox(self, xOffset, yOffset, width, height, delay, time, self.attackDamage)
end