--[[
Hey Giant Squid patrons! I'm stopped work on Gladiator, but I thought it would be good to go back through the project and add some comments
since there's some good stuff in here.

Below is the overarching file structure for the project. In each main folder, I expound more on the sub-folders and files in
the scene files.

scripts/
    game/
        gameScene.lua the main scene that handles the main game/combat
    libraries/
        AnimatedSprite.lua - A library from Whitebrim that allows you to create animated state machines
        Signal.lua - A library from Dustin Mierau that allows you to subscribe to and send signals around the project, so you don't
                     need a direct reference to something. Quite useful - it's like having signals from Godot
    map/
        mapScene.lua - Handles the level map 
    title/
        This is empty
]]--

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/frameTimer"
import "CoreLibs/nineslice"
import "CoreLibs/ui"
import "CoreLibs/crank"
import "CoreLibs/animation"

import "scripts/libraries/Signal"
import "scripts/sceneManager"

import "scripts/game/gameScene"
import "scripts/map/mapScene"
import "scripts/map/shop/shopScene"

local pd <const> = playdate
local gfx <const> = pd.graphics

PLAYER_GROUP = 1
ENEMY_GROUP = 2

MAX_WAVE = 0
CUR_WAVE = 1

CUR_AREA = "MOUNTAINS"
CUR_LEVEL = 5
GOLD = 1000

PURCHASED_ITEMS = {}

local gameData = pd.datastore.read()
if gameData then
    MAX_WAVE = gameData.maxWave
end

GROUND_LEVEL = 176
LEFT_WALL = -336
RIGHT_WALL = 336

PLAYER_X = 0

SceneManager = SceneManager()
SignalController = Signal()

-- GameScene()
MapScene()
-- ShopScene()

function pd.update()
    gfx.sprite.update()
    pd.timer.updateTimers()
    pd.frameTimer.updateTimers()
    SceneManager:update()
    -- playdate.drawFPS(10, 10)
end

function pd.gameWillTerminate()
    pd.datastore.write({
        maxWave = MAX_WAVE
    })
end

function pd.gameWillSleep()
    pd.datastore.write({
        maxWave = MAX_WAVE
    })
end
