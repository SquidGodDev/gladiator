
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "scripts/game/player/player"

local pd <const> = playdate
local gfx <const> = pd.graphics

local function initialize()
    gfx.setBackgroundColor(gfx.kColorBlack)
    Player(200, 160)
    local groundImage = gfx.image.new("images/background/ground")
    local groundSprite = gfx.sprite.new(groundImage)
    groundSprite:setZIndex(-200)
    groundSprite:moveTo(200, 120)
    groundSprite:add()
    -- local backgroundImage = gfx.image.new("images/background")
    -- gfx.sprite.setBackgroundDrawingCallback(
    --     function(x, y, width, height)
    --         gfx.setClipRect(x, y, width, height) -- let's only draw the part of the screen that's dirty
    --         backgroundImage:draw(0, 0)
    --         gfx.clearClipRect() -- clear so we don't interfere with drawing that comes after this
    --     end
    -- )
end

initialize()

function pd.update()
    gfx.sprite.update()
    pd.timer.updateTimers()
end
