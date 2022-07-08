
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/frameTimer"

import "scripts/game/player/player"
import "scripts/game/parallax"
import "scripts/game/enemies/wolf"

PLAYER_GROUP = 1
ENEMY_GROUP = 2

GROUND_LEVEL = 176

PLAYER_X = 200

local pd <const> = playdate
local gfx <const> = pd.graphics

local function initialize()
    math.randomseed(playdate.getSecondsSinceEpoch())
    local player = Player(200)
    local groundImage = gfx.image.new("images/background/background")
    local groundSprite = gfx.sprite.new(groundImage)
    groundSprite:setZIndex(-200)
    groundSprite:moveTo(200, 120)
    groundSprite:add()
    local skyImage = gfx.image.new("images/background/sky")
    local skySprite = gfx.sprite.new(skyImage)
    skySprite:setIgnoresDrawOffset(true)
    skySprite:setZIndex(-500)
    skySprite:moveTo(200, 120)
    skySprite:add()
    Wolf(220)

    -- local darkColumns = gfx.image.new("images/background/ditheredColumn2")
    -- Parallax(player, 10, 120, 48, darkColumns)
    -- local darkestColumns = gfx.image.new("images/background/ditheredColumn1")
    -- Parallax(player, 20, 120, 24, darkestColumns)
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
    pd.frameTimer.updateTimers()
    -- playdate.drawFPS(10, 10)
end
