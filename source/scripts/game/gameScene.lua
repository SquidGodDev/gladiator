import "scripts/game/player/player"
import "scripts/game/level/waveController"

local pd <const> = playdate
local gfx <const> = playdate.graphics

class('GameScene').extends()

function GameScene:init()
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
end