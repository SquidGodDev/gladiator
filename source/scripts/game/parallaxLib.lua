-- Source: frankbsad (Rob) https://devforum.play.date/t/a-list-of-helpful-libraries-and-code/221/93

local pd <const> = playdate
local gfx <const> = pd.graphics

function math.ring(a, min, max)
  if min > max then
    min, max = max, min
  end
  return min + (a-min)%(max-min)
end

class("Parallax").extends(gfx.sprite)

function Parallax:init(player)
 Parallax.super.init(self)
 self.player = player
 self:setSize(400, 240)
 self:moveTo(200, 120)
 self:add()
 self:setZIndex(-500)
 self.layers = {}
end

function Parallax:draw(...)
 gfx.setClipRect(...)
 for _, layer in ipairs(self.layers) do
   local img = layer.image
   -- lock offset to steps of 2 to reduce flashing
   local offset = layer.offset - (layer.offset % 2)
   local w = layer.width
   img:draw(self.x+offset, self.y)
   if offset < 0 or offset > w - self.width then
     if offset > 0 then
       img:draw(self.x+offset-w, self.y)
     else
       img:draw(self.x+offset+w, self.y)
     end
   end
 end
 gfx.clearClipRect()
end

function Parallax:addLayer(img, depth)
 local w, _ = img:getSize()
 local layer = {}
 layer.image = img
 layer.depth = depth
 layer.offset = 0
 layer.width = w
 table.insert(self.layers, layer)
end

function Parallax:scroll(delta)
 for _, layer in ipairs(self.layers) do
   layer.offset = math.ring(
     layer.offset + (delta * layer.depth),
     -layer.width, 0
   )
 end
 self:markDirty()
end

function Parallax:update()
    self:scroll(-self.player.velocity)
end