local pd <const> = playdate
local gfx <const> = pd.graphics

class("Parallax").extends(gfx.sprite)

function Parallax:init(player, height, rate, image)
    Parallax.super.init(self)
    self.rate = rate
    self.player = player
    self:setImage(image)
    self:moveTo(200, height)
    self:add()
    self:setZIndex(math.floor(-10000 / rate))
end

function Parallax:update()
    self:moveBy(-self.player.velocity / self.rate, 0)
end