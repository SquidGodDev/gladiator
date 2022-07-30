local pd <const> = playdate
local gfx <const> = pd.graphics

class('SpinAttackMeter').extends(gfx.sprite)

function SpinAttackMeter:init(player, meterMax)
    self.meterMax = meterMax
    self.meterValue = self.meterMax
    self.spinAvailable = true
    self.player = player

    self.meterWidth = 60
    self.meterHeight = 10
    self.meterBorder = 4
    self.meterRadius = 4

    self:add()
end

function SpinAttackMeter:deplete()
    if not self.spinAvailable then
        return false
    elseif self.meterValue <= 0 then
        self.spinAvailable = false
        return false
    end
    self.meterValue -= 1
    return true
end

function SpinAttackMeter:recharge(amount)
    self.meterValue += amount
    if self.meterValue >= self.meterMax then
        self.meterValue = self.meterMax
        self.spinAvailable = true
    end
end

function SpinAttackMeter:update()
    self:moveTo(self.player.x, self.player.y - 50)
    -- if not self.spinAvailable then
    --     self.meterValue += 1
    --     if self.meterValue >= self.meterMax then
    --         self.spinAvailable = true
    --     end
    -- end

    self:setVisible(self.meterValue < self.meterMax and self.meterValue > 0)
    local meterImage = gfx.image.new(self.meterWidth, self.meterHeight)
    gfx.pushContext(meterImage)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRoundRect(0, 0, self.meterWidth, self.meterHeight, self.meterRadius)
        gfx.setColor(gfx.kColorBlack)
        if not self.spinAvailable then
            gfx.setDitherPattern(0.5, gfx.image.kDitherTypeDiagonalLine)
        end
        local fillWidth = (self.meterValue / self.meterMax) * (self.meterWidth - self.meterBorder)
        gfx.fillRoundRect(self.meterBorder / 2, self.meterBorder / 2, fillWidth, self.meterHeight - self.meterBorder, self.meterRadius)
    gfx.popContext()
    self:setImage(meterImage)
end