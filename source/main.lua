
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
