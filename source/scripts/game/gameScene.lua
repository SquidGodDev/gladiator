-- This is the scene that handles the main game/combat. This file itself doesn't have much, but it does have a lot of
-- sub elements that do a lot. Here's the file structure.

--[[
    enemies/
        basicEnemies/
            basicEnemy.lua - A generic enemy with AI that wanders around, and runs and attacks the player when near. I extend
                             this to create all the different enemy types
        enemy.lua - A very simple enemy parent class that just handles setting the correct group and taking damage
        enemyHitbox.lua - Extends the hitbox class and creates an enemy hitbox with the correct collision groups
    level/
        spawnEffect.lua - Handles drawing the pillar animation that appears when an enemy spawns
        waveController.lua - Handles the wave spawning system that spawns in enemies
    player/
        healthbar.lua - Handles drawing the healthbar
        player.lua - Handles the entire player movement, attacking, and state machine
        playerHitbox.lua - Extends the hitbox class and creates a player hitbox with the correct collision groups
        spinAttackMeter.lua - Handles drawing and keeping track of the spin attack meter
        swapPopup.lua - Handles drawing and keeping track of the swap abilities
    results/
        resultsScene.lua - A temporary scene that shows how well you did with the infinite waves I added one of the weeks
        roomEndDisplay.lua - A popup that shows you how much gold you've earned
    gameScene.lua - This file
    hitbox.lua - A helper class that generates a hitbox
]]

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