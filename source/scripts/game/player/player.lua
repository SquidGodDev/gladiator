import "scripts/libraries/AnimatedSprite"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Player').extends(AnimatedSprite)

function Player:init(x, y)
    local playerSpriteSheet = gfx.imagetable.new("images/player/player-table-112-48")
    Player.super.init(self, playerSpriteSheet)
    self:addState("idle", 1, 10, {tickStep = 4})
    self:addState("run", 11, 20, {tickStep = 4})
    self:addState("attack1", 21, 26, {tickStep = 3, nextAnimation = "idle"})
    self.attack1ACFrame = 25
    self:addState("attack2", 27, 33, {tickStep = 3, nextAnimation = "idle"})
    self.attack2ACFrame = 32
    self:addState("roll", 34, 45, {tickStep = 2, nextAnimation = "idle"})
    self.rollACFrame = 44
    self:addState("slide", 46, 46)

    self.maxSpeed = 3
    self.velocity = 0
    self.startVelocity = 2
    self.acceleration = 0.3
    self.friction = 0.3
    self.rollVelocity = 4
    self:playAnimation()
    self:moveTo(x, y)
end

function Player:update()
    if self.currentState == "idle" then
        self:applyFriction()
        if pd.buttonIsPressed(pd.kButtonLeft) then
            self.velocity = -self.startVelocity
            self:changeState("run")
        elseif pd.buttonIsPressed(pd.kButtonRight) then
            self.velocity = self.startVelocity
            self:changeState("run")
        elseif pd.buttonJustPressed(pd.kButtonA) then
            self:changeState("attack1")
        elseif pd.buttonJustPressed(pd.kButtonB) then
            self:changeState("roll")
        end
    elseif self.currentState == "run" then
        if pd.buttonJustPressed(pd.kButtonA) then
            self:changeState("attack1")
        elseif pd.buttonJustPressed(pd.kButtonB) then
            self:changeState("roll")
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
            if pd.buttonJustPressed(pd.kButtonA) then
                self:changeState("attack2")
            elseif pd.buttonJustPressed(pd.kButtonB) then
                self:changeState("roll")
            end
        end
    elseif self.currentState == "attack2" then
        self:applyFriction()
        if self:getCurrentFrameIndex() >= self.attack2ACFrame then
            if pd.buttonJustPressed(pd.kButtonB) then
                self:changeState("roll")
            end
        end
    elseif self.currentState == "roll" then
        if self.globalFlip == 1 then
            self.velocity = -self.rollVelocity
        else
            self.velocity = self.rollVelocity
        end
    elseif self.currentState == "slide" then
        self:applyFriction()

        if pd.buttonJustPressed(pd.kButtonLeft) or pd.buttonJustPressed(pd.kButtonRight) then
            self:changeState("run")
        elseif pd.buttonJustPressed(pd.kButtonA) then
            self:changeState("attack1")
        elseif math.abs(self.velocity) < 1 then
            self:changeState("idle")
        elseif pd.buttonJustPressed(pd.kButtonB) then
            self:changeState("roll")
        end
    end

    self:moveBy(self.velocity, 0)

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