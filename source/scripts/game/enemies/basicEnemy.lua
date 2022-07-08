import "scripts/game/enemies/enemy"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('BasicEnemy').extends(Enemy)

function BasicEnemy:init(x, spritesheet)
    -- self.health = 100

    -- self:addState("idle", 1, 10, {tickStep = 4})
    -- self:addState("run", 11, 20, {tickStep = 4})
    -- self:addState("attack", 21, 22, {tickStep = 3, nextAnimation = "idle"})
    -- self:addState("hit", 21, 22, {tickStep = 3, nextAnimation = "idle"})
    -- self:addState("death", 21, 22, {tickStep = 3})

    -- self.idleCollisionRect = pd.geometry.rect.new(45, 10, 21, 38)
    -- self.runCollisionRect = pd.geometry.rect.new(45, 10, 21, 38)
    -- self.attackCollisionRect = pd.geometry.rect.new(45, 10, 21, 38)

    -- self.attackDamage = 5

    -- self.maxSpeed = 3
    -- self.startVelocity = 2
    -- self.acceleration = 0.3
    -- self.friction = 0.3

    -- self.paceTime = 1000

    -- self.detectRange = 30
    -- self.attackRange = 10
    -- self.attackCooldown = 500

    -- self:playAnimation()

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
    if not self.playerInRange and (math.abs(PLAYER_X - self.x) <= self.detectRange) then
        self.playerInRange = true
        self.paceTimer:remove()
        self:changeState("run")
    elseif self.playerInRange and (math.abs(PLAYER_X - self.x) >= self.detectRange) then
        self.playerInRange = false
        self:resetPaceTimer()
        self:changeState("idle")
    end

    if self.currentState == "idle" then
        self:setCollideRect(self.idleCollisionRect)
        self:applyFriction()
        if self.playerInRange then
            if not self.attackCooldownTimer then
                self:changeState("run")
            end
        end
    elseif self.currentState == "run" then
        self:setCollideRect(self.runCollisionRect)
        if self.playerInRange then
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

    if self.velocity < 0 then
        self.globalFlip = 1
    elseif self.velocity > 0 then
        self.globalFlip = 0
    end
    self:updateAnimation()
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
        if self.currentState == "idle" then
            self.movingRight = not self.movingRight
            self:changeState("run")
            self:resetPaceTimer()
        else
            self:changeState("idle")
            self:resetPaceTimer()
        end
    end)
end
