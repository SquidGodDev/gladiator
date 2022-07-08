import "scripts/game/enemies/basicEnemy"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Wolf').extends(BasicEnemy)

function Wolf:init(x)
    local wolfSpriteSheet = gfx.imagetable.new("images/enemies/wolf/wolf-table-64-48")
    Wolf.super.init(self, x, wolfSpriteSheet)

    self.health = 50

    self:addState("idle", 1, 8, {tickStep = 4})
    self:addState("run", 9, 14, {tickStep = 4})
    self:addState("attack", 21, 26, {tickStep = 3, nextAnimation = "idle"})
    self:addState("hit", 15, 15, {tickStep = 3, nextAnimation = "idle"})
    self:addState("death", 15, 20, {tickStep = 3})

    self.idleCollisionRect = pd.geometry.rect.new(11, 21, 38, 27)
    self.runCollisionRect = pd.geometry.rect.new(11, 21, 38, 27)
    self.attackCollisionRect = pd.geometry.rect.new(11, 21, 38, 27)

    self.attackDamage = 5

    self.maxSpeed = 4
    self.startVelocity = 2
    self.acceleration = 0.3
    self.friction = 0.3

    self.paceTime = 1000

    self.detectRange = 100
    self.attackRange = 30
    self.attackCooldown = 1000

    self:playAnimation()
end