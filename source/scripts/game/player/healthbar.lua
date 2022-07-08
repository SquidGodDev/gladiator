local pd <const> = playdate
local gfx <const> = pd.graphics

class('Healthbar').extends(gfx.sprite)

function Healthbar:init(maxHealth)
    self.maxHealth = maxHealth
    self.barWidth = 150
    self.barHeight = 20
    self.barCornerRadius = 10
    local healthbarImage = gfx.image.new(self.barWidth, self.barHeight)
    gfx.pushContext(healthbarImage)
        gfx.fillRoundRect(0, 0, self.barWidth, self.barHeight, self.barCornerRadius)
    gfx.popContext()
    self:setImage(healthbarImage)

    self.barX = 25
    self.barY = 25

    self:setCenter(0.0, 0.5)
    self:moveTo(self.barX, self.barY)
    self:setIgnoresDrawOffset(true)
    self:add()

    local heartImage = gfx.image.new("images/UI/heart")
    local heartSprite = gfx.sprite.new(heartImage)
    heartSprite:setIgnoresDrawOffset(true)
    heartSprite:moveTo(self.barX, self.barY)
    heartSprite:add()
end

function Healthbar:updateHealthbar(newHealth)
    if newHealth <= 0 then
        newHealth = 0
    end
    local healthbarImage = gfx.image.new(self.barWidth, self.barHeight)
    gfx.pushContext(healthbarImage)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRoundRect(0, 0, self.barWidth, self.barHeight, self.barCornerRadius)
        gfx.setColor(gfx.kColorBlack)
        gfx.drawRoundRect(0, 0, self.barWidth, self.barHeight, self.barCornerRadius)
        gfx.fillRoundRect(0, 0, (newHealth / self.maxHealth) * self.barWidth, self.barHeight, self.barCornerRadius)
    gfx.popContext()
    self:setImage(healthbarImage)
end