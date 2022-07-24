import "scripts/game/enemies/basicEnemies/wolf"
import "scripts/game/enemies/basicEnemies/rat"
import "scripts/game/enemies/basicEnemies/ghost"
import "scripts/game/enemies/basicEnemies/worm"
import "scripts/game/enemies/basicEnemies/minotaur"
import "scripts/game/level/spawnEffect"
import "scripts/map/mapScene"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('WaveController').extends(gfx.sprite)

function WaveController:init(enemyList)
    SignalController:subscribe("enemy_died", self, function()
        self.currentEnemies -= 1
        self.enemiesKilled += 1
        if self.enemiesKilled >= self.totalEnemies then
            self.wave += 1
            self.enemiesKilled = 0
            self.spawnedEnemies = 0
            self.totalEnemies = self.totalEnemiesBase + self.wave * self.totalEnemiesBase

            if self.wave >= 3 then
                CUR_LEVEL += 1
                self:stopSpawning()
                SceneManager:switchScene(MapScene)
            end
        end
    end)
    self.enemyTypes = enemyList
    self.spawnMin = LEFT_WALL + 10
    self.spawnMax = RIGHT_WALL - 10

    self.currentEnemies = 0
    self.enemiesKilled = 0
    self.spawnedEnemies = 0
    self.wave = 1
    self.maxEnemies = 3
    self.totalEnemiesBase = 3
    self.waveMultiplier = 3
    self.totalEnemies = self.totalEnemiesBase + self.wave * self.totalEnemiesBase

    self.spawnTimer = pd.timer.new(1000, function()
        if self.currentEnemies < self.maxEnemies + self.wave and self.spawnedEnemies < self.totalEnemies then
            self.currentEnemies += 1
            self.spawnedEnemies += 1
            local randomEnemy = self.enemyTypes[math.random(#self.enemyTypes)]
            SpawnEffect(math.random(self.spawnMin, self.spawnMax), randomEnemy)
        end
    end)
    self.spawnTimer.repeats = true

    self.progressBarWidth = 250
    self.progressBarHeight = 20
    self.progressBarRadius = 15
    self.border = 2

    self.waveTextSprite = gfx.sprite.new(80, 20)
    self.waveTextSprite:setCenter(0, 0.5)
    self.waveTextSprite:moveTo(20, 212)
    self.waveTextSprite:setIgnoresDrawOffset(true)
    self.waveTextSprite:add()

    self:setIgnoresDrawOffset(true)
    self:moveTo(240, 210)
    self:add()
end

function WaveController:update()
    local progressImage = gfx.image.new(self.progressBarWidth, self.progressBarHeight)
    gfx.pushContext(progressImage)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRoundRect(0, 0, self.progressBarWidth, self.progressBarHeight, self.progressBarRadius)
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRoundRect(self.border, self.border, (self.enemiesKilled / self.totalEnemies) * (self.progressBarWidth - self.border*2), self.progressBarHeight - self.border*2, self.progressBarRadius)
    gfx.popContext()
    self:setImage(progressImage)

    local waveText = "Wave: " .. tostring(self.wave)
    local waveTextImage = gfx.image.new(gfx.getTextSize(waveText))
    gfx.pushContext(waveTextImage)
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        -- gfx.drawTextAligned(waveText, 0, 0, kTextAlignment.center)
        gfx.drawText(waveText, 0, 0)
    gfx.popContext()
    self.waveTextSprite:setImage(waveTextImage)
end

function WaveController:stopSpawning()
    self.spawnTimer:remove()
end