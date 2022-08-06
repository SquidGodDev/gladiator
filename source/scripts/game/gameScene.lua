import "scripts/game/player/player"
import "scripts/game/level/waveController"

local pd <const> = playdate
local gfx <const> = playdate.graphics

class('GameScene').extends()

function GameScene:init(enemyList)
    math.randomseed(playdate.getSecondsSinceEpoch())
    local waveController = WaveController(enemyList)
    local player = Player(PLAYER_X, waveController)
    if CUR_AREA == "SEA" then
        self:drawSea()
    elseif CUR_AREA == "NIGHT" then
        self:drawNight()
    elseif CUR_AREA == "MOUNTAINS" then
        self:drawMountains()
    end
end

function GameScene:drawSea()
    local backgroundImage = gfx.image.new("images/background/sky")
    self:drawBackground(backgroundImage)
    local groundImage = gfx.image.new("images/background/background")
    self:drawGround(groundImage)
end

function GameScene:drawNight()
    local backgroundImage = gfx.image.new("images/background/nightSky")
    self:drawBackground(backgroundImage)
    local groundImage = gfx.image.new("images/background/nightGround")
    self:drawGround(groundImage)
end

function GameScene:drawMountains()
    local backgroundImage = gfx.image.new("images/background/mountains")
    self:drawBackground(backgroundImage)
    local groundImage = gfx.image.new("images/background/mountainGround")
    self:drawGround(groundImage)
end

function GameScene:drawBackground(backgroundImage)
    local backgroundSprite = gfx.sprite.new(backgroundImage)
    backgroundSprite:setIgnoresDrawOffset(true)
    backgroundSprite:setZIndex(-500)
    backgroundSprite:moveTo(200, 120)
    backgroundSprite:add()
end

function GameScene:drawGround(groundImage)
    local groundSprite = gfx.sprite.new(groundImage)
    groundSprite:setZIndex(-200)
    groundSprite:moveTo(0, 120)
    groundSprite:add()
end