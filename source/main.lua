
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/frameTimer"

import "scripts/libraries/Signal"
import "scripts/sceneManager"

import "scripts/game/gameScene"

local pd <const> = playdate
local gfx <const> = pd.graphics

PLAYER_GROUP = 1
ENEMY_GROUP = 2

MAX_WAVE = 0
CUR_WAVE = 1

GROUND_LEVEL = 176
LEFT_WALL = -528
RIGHT_WALL = 528

PLAYER_X = 0

SceneManager = SceneManager()
SignalController = Signal()

GameScene()

function pd.update()
    gfx.sprite.update()
    pd.timer.updateTimers()
    pd.frameTimer.updateTimers()
    SceneManager:update()
    -- playdate.drawFPS(10, 10)
end
