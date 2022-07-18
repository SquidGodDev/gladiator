import "scripts/game/enemies/enemy"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('BasicEnemy').extends(Enemy)

function BasicEnemy:init(x, spritesheet)
    local isMovingRight = math.random(2)
    if isMovingRight == 1 then
        self.movingRight = true
    else
        self.movingRight = false
    end
    self.paceTimer = pd.timer.new(500, function()
        self:changeState("run")
        self:resetPaceTimer()
    end)

    self.velocity = 0
    self.playerInRange = false
    BasicEnemy.super.init(self, x, spritesheet)
end

function Enemy:update()
    if self.currentState == "death" then
        self:applyFriction()
        self:updateAnimation()
        if self.attackHitbox then
            self.attackHitbox:cancel()
            self.attackHitbox = nil
        end
        return
    elseif self.died then
        if self.attackHitbox then
            self.attackHitbox:cancel()
            self.attackHitbox = nil
        end
        return
    end

    if not self.died then
        if not self.playerInRange and (math.abs(PLAYER_X - self.x) <= self.detectRange) then
            self.playerInRange = true
            self.paceTimer:remove()
            self:changeState("run")
        elseif self.playerInRange and (math.abs(PLAYER_X - self.x) >= self.detectRange) then
            self.playerInRange = false
            self:resetPaceTimer()
            self:changeState("idle")
        end
    end

    if self.currentState == "idle" then
        self:setCollideRect(self.idleCollisionRect)
        self:applyFriction()
        if self.playerInRange and not self.died then
            if not self.attackCooldownTimer then
                self:changeState("run")
            end
        end
    elseif self.currentState == "run" then
        self:setCollideRect(self.runCollisionRect)
        if self.playerInRange and not self.died then
            self.movingRight = self.x <= PLAYER_X
            if math.abs(PLAYER_X - self.x) <= self.attackRange then
                self:changeState("attack")
            end
        end
        if self.movingRight then
            self.velocity += self.acceleration
            if self.velocity >= self.maxSpeed then
                self.velocity = self.maxSpeed
            end
        else
            self.velocity -= self.acceleration
            if self.velocity <= -self.maxSpeed then
                self.velocity = -self.maxSpeed
            end
        end
    elseif self.currentState == "attack" then
        self:applyFriction()
        if not self.attackCooldownTimer then
            self.attackCooldownTimer = pd.timer.new(self.attackCooldown, function()
                self.attackCooldownTimer = nil
            end)
        end
    elseif self.currentState == "hit" then
        self:applyFriction()
    elseif self.currentState == "death" then
        self:applyFriction()
    end

    self:moveBy(self.velocity, 0)
    if self.x <= LEFT_WALL then
        self:moveTo(LEFT_WALL, self.y)
    elseif self.x >= RIGHT_WALL then
        self:moveTo(RIGHT_WALL, self.y)
    end

    if self.velocity < 0 then
        self.globalFlip = 1
    elseif self.velocity > 0 then
        self.globalFlip = 0
    end
    self:updateAnimation()
end

function BasicEnemy:damage(amount)
    if self.died then
        if self.attackHitbox then
            self.attackHitbox:cancel()
            self.attackHitbox = nil
        end
        return
    end
    BasicEnemy.super.damage(self, amount)
    if self.health <= 0 and not self.died then
        SignalController:notify("enemy_died")
        self.died = true
        if self.attackCooldownTimer then
            self.attackCooldownTimer:remove()
            self.attackCooldownTimer = nil
        end
        if self.stunTimer then
            self.stunTimer:remove()
            self.stunTimer = nil
        end
        self.paceTimer:remove()
        self:changeState("death")
        return
    end

    if self.hitVelocity ~= 0 then
        if PLAYER_X < self.x then
            self.velocity = self.hitVelocity
        else
            self.velocity = -self.hitVelocity
        end
    end

    if self.getsStunned then
        if self.stunTimer then
            self.stunTimer:remove()
        end
        self.paceTimer:remove()
        self.stunTimer = pd.timer.new(self.hitStunTime, function()
            self.stunTimer = nil
            self:resetPaceTimer()
            if self.attackCooldownTimer then
                self.attackCooldownTimer:remove()
            end
            self.attackCooldownTimer = pd.timer.new(self.attackCooldown * 0.2, function()
                self.attackCooldownTimer = nil
            end)
            self:changeState("idle")
        end)
        self:changeState("hit")
        if self.attackHitbox then
            self.attackHitbox:cancel()
            self.attackHitbox = nil
        end
    end
end

function BasicEnemy:applyFriction()
    if self.velocity > 0 then
        self.velocity -= self.friction
    elseif self.velocity < 0 then
        self.velocity += self.friction
    end

    if math.abs(self.velocity) < 0.5 then
        self.velocity = 0
    end
end

function BasicEnemy:resetPaceTimer()
    local randomPaceTime = math.random(math.floor(self.paceTime * 0.8), math.floor(self.paceTime * 1.2))
    self.paceTimer = pd.timer.new(randomPaceTime, function()
        if not self.died then
            if self.currentState == "idle" then
                self.movingRight = not self.movingRight
                self:changeState("run")
                self:resetPaceTimer()
            else
                self:changeState("idle")
                self:resetPaceTimer()
            end
        end
    end)
end
