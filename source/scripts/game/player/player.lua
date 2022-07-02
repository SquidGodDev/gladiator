import "scripts/libraries/AnimatedSprite"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Player').extends(AnimatedSprite)

function Player:init(x, y)
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
    self.slideAttackACFrame = slideAttackEndFrame -1

    self.idleCollisionRect = pd.geometry.rect.new(45, 10, 21, 38)
    self.runCollisionRect = pd.geometry.rect.new(45, 10, 21, 38)
    self.rollCollisionRect = pd.geometry.rect.new(45, 10, 21, 38)
    self.slideAttackCollisionRect = pd.geometry.rect.new(37, 31, 38, 17)

    self.maxSpeed = 3
    self.velocity = 0
    self.startVelocity = 2
    self.acceleration = 0.3
    self.friction = 0.3
    self.rollVelocity = 4
    self.slideAttackVelocity = 4
    self:playAnimation()
    self:setCenter(0.5, 1.0)
    self:moveTo(x, y)
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
            self:changeState("attack1")
        elseif pd.buttonJustPressed(pd.kButtonB) then
            self:changeState("roll")
        elseif pd.buttonJustPressed(pd.kButtonDown) then
            self:changeState("slideAttack")
        end
    elseif self.currentState == "run" then
        self:setCollideRect(self.runCollisionRect)
        if pd.buttonIsPressed(pd.kButtonA) then
            self:changeState("attack1")
        elseif pd.buttonJustPressed(pd.kButtonB) then
            self:changeState("roll")
        elseif pd.buttonIsPressed(pd.kButtonDown) then
            self:changeState("slideAttack")
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
                self:changeState("attack2")
            elseif pd.buttonIsPressed(pd.kButtonB) then
                self:switchPlayerDirection()
                self:changeState("roll")
            elseif pd.buttonIsPressed(pd.kButtonDown) then
                self:switchPlayerDirection()
                self:changeState("slideAttack")
            end
        end
    elseif self.currentState == "attack2" then
        self:applyFriction()
        if self:getCurrentFrameIndex() >= self.attack2ACFrame then
            if pd.buttonIsPressed(pd.kButtonA) then
                self:switchPlayerDirection()
                self:changeState("attack1")
            elseif pd.buttonIsPressed(pd.kButtonB) then
                self:switchPlayerDirection()
                self:changeState("roll")
            elseif pd.buttonIsPressed(pd.kButtonDown) then
                self:switchPlayerDirection()
                self:changeState("slideAttack")
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
            self:changeState("attack1")
        elseif math.abs(self.velocity) < 1 then
            self:changeState("idle")
        elseif pd.buttonJustPressed(pd.kButtonB) then
            self:changeState("roll")
        elseif pd.buttonIsPressed(pd.kButtonDown) then
            self:changeState("slideAttack")
        end
    elseif self.currentState == "slideAttack" then
        self:setCollideRect(self.slideAttackCollisionRect)
        if self.globalFlip == 1 then
            self.velocity = -self.slideAttackVelocity
        else
            self.velocity = self.slideAttackVelocity
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

function Player:switchPlayerDirection()
    if pd.buttonIsPressed(pd.kButtonLeft) then
        self.globalFlip = 1
    elseif pd.buttonIsPressed(pd.kButtonRight) then
        self.globalFlip = 0
    end
end