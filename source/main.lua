
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/frameTimer"

import "scripts/libraries/Signal"

import "scripts/game/player/player"
import "scripts/game/enemies/basicEnemies/wolf"
import "scripts/game/enemies/basicEnemies/rat"
import "scripts/game/enemies/basicEnemies/ghost"
import "scripts/game/enemies/basicEnemies/worm"
import "scripts/game/enemies/basicEnemies/minotaur"

import "scripts/game/level/waveController"

PLAYER_GROUP = 1
ENEMY_GROUP = 2

GROUND_LEVEL = 176
LEFT_WALL = -528
RIGHT_WALL = 528

PLAYER_X = 0

local pd <const> = playdate
local gfx <const> = pd.graphics

local function initialize()
    SignalController = Signal()

    math.randomseed(playdate.getSecondsSinceEpoch())
    local player = Player(PLAYER_X)
    local groundImage = gfx.image.new("images/background/background")
    local groundSprite = gfx.sprite.new(groundImage)
    groundSprite:setZIndex(-200)
    groundSprite:moveTo(0, 120)
    groundSprite:add()
    local skyImage = gfx.image.new("images/background/sky")
    local skySprite = gfx.sprite.new(skyImage)
    skySprite:setIgnoresDrawOffset(true)
    skySprite:setZIndex(-500)
    skySprite:moveTo(200, 120)
    skySprite:add()

    WaveController()

    -- Rat(300)
    -- Minotaur(220)
    -- Worm(500)
    -- Ghost(400)
    -- Minotaur(150)
    -- Minotaur(300)
    -- Minotaur(400)
    -- Worm(100)
    -- Worm(500)
end

initialize()

function pd.update()
    gfx.sprite.update()
    pd.timer.updateTimers()
    pd.frameTimer.updateTimers()
    -- playdate.drawFPS(10, 10)
end
