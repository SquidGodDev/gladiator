import "scripts/libraries/AnimatedSprite"
import "scripts/game/player/playerHitbox"
import "scripts/game/player/healthbar"
import "scripts/game/player/spinAttackMeter"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Player').extends(AnimatedSprite)

function Player:init(x)
    self.health = 100
    self.healthbar = Healthbar(self.health)
    self.spinAttackMeter = SpinAttackMeter(self)

    local playerSpriteSheet = gfx.imagetable.new("images/player/player-table-112-48")
    Player.super.init(self, playerSpriteSheet)
    self:addState("idle", 1, 10, {tickStep = 4})
    self:addState("run", 11, 20, {tickStep = 4})

    local attack1EndFrame = 26
    self:addState("attack1", 21, attack1EndFrame, {tickStep = 3, nextAnimation = "idle"})
    self.attack1ACFrame = attack1EndFrame - 1

    local attack2EndFrame = 33
    self:addState("attack2", 27, attack2EndFrame, {tickStep = 3, nextAnimation = "idle"})
    self.attack2ACFrame = attack2EndFrame - 1

    local rollStartFrame, rollEndFrame = 34, 45
    self:addState("roll", rollStartFrame, rollEndFrame, {tickStep = 2, nextAnimation = "idle"})
    self.rollACFrame = rollEndFrame - 1
    self.rollIFrameStart = rollStartFrame + 1
    self.rollIFrameEnd = rollEndFrame - 1

    self:addState("slide", 46, 46)

    local slideAttackEndFrame = 55
    self:addState("slideAttack", 47, slideAttackEndFrame, {tickStep = 2, nextAnimation = "idle"})
    self.slideAttackACFrame = slideAttackEndFrame - 1

    local spinAttackStartFrame = 56
    local spinLeftSwingFrame = spinAttackStartFrame + 1
    local spinRightSwingFrame = spinAttackStartFrame + 3
    self:addState("spinAttack", spinAttackStartFrame, 60, {tickStep = 2})
    self.states["spinAttack"].onFrameChangedEvent = function()
        if self:getCurrentFrameIndex() == spinLeftSwingFrame then
            self:createSpinAttackLeftHitbox()
        elseif self:getCurrentFrameIndex() == spinRightSwingFrame then
            self:createSpinAttackRightHitbox()
        end
    end
    self.spinAttackThreshold = 10

    self.idleCollisionRect = pd.geometry.rect.new(45, 10, 21, 38)
    self.runCollisionRect = pd.geometry.rect.new(45, 10, 21, 38)
    self.rollCollisionRect = pd.geometry.rect.new(45, 10, 21, 38)
    self.slideAttackCollisionRect = pd.geometry.rect.new(37, 31, 38, 17)
    self:setGroups(PLAYER_GROUP)
    self.collisionResponse = gfx.sprite.kCollisionTypeOverlap

    self.attack1Damage = 5
    self.attack2Damage = 7
    self.slideAttackDamage = 3
    self.spinAttackDamage = 3

    self.maxSpeed = 3
    self.velocity = 0
    self.startVelocity = 2
    self.acceleration = 0.3
    self.friction = 0.3
    self.rollVelocity = 4
    self.slideAttackVelocity = 4
    self:playAnimation()
    self:setCenter(0.5, 1.0)
    self:moveTo(x, GROUND_LEVEL)
end

function Player:damage(amount)
    self.health -= amount
    self.healthbar:updateHealthbar(self.health)
end

function Player:update()
    if self.currentState == "idle" then
        self:setCollideRect(self.idleCollisionRect)
        self:applyFriction()
        if pd.buttonIsPressed(pd.kButtonLeft) then
            self.velocity = -self.startVelocity
            self:changeState("run")
        elseif pd.buttonIsPressed(pd.kButtonRight) then
            self.velocity = self.startVelocity
            self:changeState("run")
        elseif pd.buttonIsPressed(pd.kButtonA) then
            self:switchToAttack1()
        elseif pd.buttonJustPressed(pd.kButtonB) then
            self:changeState("roll")
        elseif pd.buttonJustPressed(pd.kButtonDown) then
            self:switchToSlideAttack()
        elseif self:crankIsSpun() then
            self:changeState("spinAttack")
        end
    elseif self.currentState == "run" then
        self:setCollideRect(self.runCollisionRect)
        if pd.buttonIsPressed(pd.kButtonA) then
            self:switchToAttack1()
        elseif pd.buttonJustPressed(pd.kButtonB) then
            self:changeState("roll")
        elseif self:crankIsSpun() then
            self:changeState("spinAttack")
        elseif pd.buttonIsPressed(pd.kButtonDown) then
            self:switchToSlideAttack()
        elseif pd.buttonIsPressed(pd.kButtonLeft) then
            if self.velocity > 0 then
                self.velocity = 0
            end
            self.velocity -= self.acceleration
            if self.velocity <= -self.maxSpeed then
                self.velocity = -self.maxSpeed
            end
        elseif pd.buttonIsPressed(pd.kButtonRight) then
            if self.velocity < 0 then
                self.velocity = 0
            end
            self.velocity += self.acceleration
            if self.velocity >= self.maxSpeed then
                self.velocity = self.maxSpeed
            end
        else
            self:changeState("slide")
        end
    elseif self.currentState == "attack1" then
        self:applyFriction()
        if self:getCurrentFrameIndex() >= self.attack1ACFrame then
            if pd.buttonIsPressed(pd.kButtonA) then
                self:switchPlayerDirection()
                self:switchToAttack2()
            elseif pd.buttonIsPressed(pd.kButtonB) then
                self:switchPlayerDirection()
                self:changeState("roll")
            elseif pd.buttonIsPressed(pd.kButtonDown) then
                self:switchPlayerDirection()
                self:switchToSlideAttack()
            end
        end
    elseif self.currentState == "attack2" then
        self:applyFriction()
        if self:getCurrentFrameIndex() >= self.attack2ACFrame then
            if pd.buttonIsPressed(pd.kButtonA) then
                self:switchPlayerDirection()
                self:switchToAttack1()
            elseif pd.buttonIsPressed(pd.kButtonB) then
                self:switchPlayerDirection()
                self:changeState("roll")
            elseif pd.buttonIsPressed(pd.kButtonDown) then
                self:switchPlayerDirection()
                self:switchToSlideAttack()
            end
        end
    elseif self.currentState == "roll" then
        local curFrameIndex = self:getCurrentFrameIndex()
        if curFrameIndex <= self.rollIFrameStart then
            self:setCollideRect(self.rollCollisionRect)
        elseif curFrameIndex >= self.rollIFrameEnd then
            self:setCollideRect(self.rollCollisionRect)
        else
            self:clearCollideRect()
        end
        if self.globalFlip == 1 then
            self.velocity = -self.rollVelocity
        else
            self.velocity = self.rollVelocity
        end
    elseif self.currentState == "slide" then
        self:setCollideRect(self.idleCollisionRect)
        self:applyFriction()

        if pd.buttonJustPressed(pd.kButtonLeft) or pd.buttonJustPressed(pd.kButtonRight) then
            self:changeState("run")
        elseif pd.buttonJustPressed(pd.kButtonA) then
            self:switchToAttack1()
        elseif math.abs(self.velocity) < 1 then
            self:changeState("idle")
        elseif pd.buttonJustPressed(pd.kButtonB) then
            self:changeState("roll")
        elseif pd.buttonIsPressed(pd.kButtonDown) then
            self:switchToSlideAttack()
        end
    elseif self.currentState == "slideAttack" then
        self:setCollideRect(self.slideAttackCollisionRect)
        if self.globalFlip == 1 then
            self.velocity = -self.slideAttackVelocity
        else
            self.velocity = self.slideAttackVelocity
        end
    elseif self.currentState == "spinAttack" then
        self:setCollideRect(self.idleCollisionRect)
        if pd.buttonIsPressed(pd.kButtonLeft) then
            if self.velocity > 0 then
                self.velocity = 0
            end
            self.velocity -= self.acceleration
            if self.velocity <= -self.maxSpeed then
                self.velocity = -self.maxSpeed
            end
        elseif pd.buttonIsPressed(pd.kButtonRight) then
            if self.velocity < 0 then
                self.velocity = 0
            end
            self.velocity += self.acceleration
            if self.velocity >= self.maxSpeed then
                self.velocity = self.maxSpeed
            end
        else
            self:applyFriction()
        end

        local crankChange, acceleratedCrankChange = pd.getCrankChange()
        if acceleratedCrankChange == 0 then
            self:changeState("idle")
        elseif not self.spinAttackMeter:deplete() then
            self:changeState("idle")
        end
    end

    self:moveBy(self.velocity, 0)
    gfx.setDrawOffset(-self.x + 200, 0)

    if self.velocity < 0 then
        self.globalFlip = 1
    elseif self.velocity > 0 then
        self.globalFlip = 0
    end
    self:updateAnimation()

    PLAYER_X = self.x
end

function Player:applyFriction()
    if self.velocity > 0 then
        self.velocity -= self.friction
    elseif self.velocity < 0 then
        self.velocity += self.friction
    end

    if math.abs(self.velocity) < 0.5 then
        self.velocity = 0
    end
end

function Player:crankIsSpun()
    local crankChange, acceleratedCrankChange = pd.getCrankChange()
    if math.abs(acceleratedCrankChange) >= self.spinAttackThreshold then
        return self.spinAttackMeter:deplete()
    end
    return false
end

function Player:switchPlayerDirection()
    if pd.buttonIsPressed(pd.kButtonLeft) then
        self.globalFlip = 1
    elseif pd.buttonIsPressed(pd.kButtonRight) then
        self.globalFlip = 0
    end
end

function Player:switchToAttack1()
    self:changeState("attack1")
    self:createAttack1Hitbox()
end

function Player:switchToAttack2()
    self:changeState("attack2")
    self:createAttack2Hitbox()
end

function Player:switchToSlideAttack()
    self:changeState("slideAttack")
    self:createSlideAttackHitbox()
end

function Player:createAttack1Hitbox()
    local xOffset, yOffset = 0, -40
    local width, height = 60, 50
    local delay, time = 4, 6
    PlayerHitbox(self, xOffset, yOffset, width, height, delay, time, self.attack1Damage)
end

function Player:createAttack2Hitbox()
    local xOffset, yOffset = -30, -40
    local width, height = 80, 50
    local delay, time = 4, 6
    PlayerHitbox(self, xOffset, yOffset, width, height, delay, time, self.attack2Damage)
end

function Player:createSlideAttackHitbox()
    local xOffset, yOffset = -20, -20
    local width, height = 45, 20
    local delay, time = 1, 15
    PlayerHitbox(self, xOffset, yOffset, width, height, delay, time, self.attack2Damage)
end

function Player:createSpinAttackRightHitbox()
    local xOffset, yOffset = -30, -30
    local width, height = 80, 30
    local delay, time = 0, 2
    PlayerHitbox(self, xOffset, yOffset, width, height, delay, time, self.spinAttackDamage)
end

function Player:createSpinAttackLeftHitbox()
    local xOffset, yOffset = -45, -30
    local width, height = 80, 30
    local delay, time = 0, 2
    PlayerHitbox(self, xOffset, yOffset, width, height, delay, time, self.spinAttackDamage)
end