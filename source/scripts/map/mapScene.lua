import "scripts/game/player/player"
import "scripts/game/level/waveController"

import "scripts/game/enemies/basicEnemies/wolf"
import "scripts/game/enemies/basicEnemies/rat"
import "scripts/game/enemies/basicEnemies/ghost"
import "scripts/game/enemies/basicEnemies/worm"
import "scripts/game/enemies/basicEnemies/minotaur"

import "scripts/game/gameScene"
import "scripts/map/shop/shopScene"

local pd <const> = playdate
local gfx <const> = playdate.graphics

class('MapScene').extends(gfx.sprite)

function MapScene:init()
    self.map = {
        {
            {
                type = "enemy",
                enemies = {
                    Worm
                }
            }
        },
        {
            {
                type = "enemy",
                enemies = {
                    Worm,
                    Rat
                }
            }
        },
        {
            {
                type = "enemy",
                enemies = {
                    Worm,
                    Rat,
                    Ghost
                }
            },
            {
                type = "shop",
            }
        },
        {
            {
                type = "shop"
            }
        },
        {
            {
                type = "enemy",
                enemies = {
                    Worm,
                    Rat,
                    Wolf,
                    Ghost
                }
            }
        },
        {
            {
                type = "elite",
                enemies = {
                    Minotaur
                }
            },
            {
                type = "enemy",
                enemies = {
                    Worm,
                    Rat,
                    Wolf,
                    Ghost
                }
            }
        },
        {
            {
                type = "enemy",
                enemies = {
                    Wolf,
                    Ghost,
                    Minotaur
                }
            }
        },
        {
            {
                type = "shop"
            }
        }
    }

    self.shopImage = gfx.image.new("images/map/shop")
    self.skullImage = gfx.image.new("images/map/skull")
    self.eliteImage = gfx.image.new("images/map/elite")

    self.mapIconWidth = self.shopImage:getSize()
    self.mapPadding = 200
    self.mapYOffset = 60

    self.dividerWidth = 80

    self.inputEnabled = false

    self.selector = 1
    self.curLevelSprites = {}

    for index, levelOptions in ipairs(self.map) do
        local iconX = (index - 1) * (self.mapIconWidth * 2) + self.mapPadding
        if #levelOptions == 1 then
            local iconY = 120
            local curMapSprite = self:createMapSprite(iconX, iconY, levelOptions[1].type, index)
            if CUR_LEVEL == index then
                table.insert(self.curLevelSprites, curMapSprite)
            end
        else
            local iconY = 120 - self.mapYOffset
            local firstMapSprite = self:createMapSprite(iconX, iconY, levelOptions[1].type, index)
            iconY = 120 + self.mapYOffset
            local secondMapSprite = self:createMapSprite(iconX, iconY, levelOptions[2].type, index)
            if CUR_LEVEL == index then
                table.insert(self.curLevelSprites, firstMapSprite)
                table.insert(self.curLevelSprites, secondMapSprite)
            end
        end
        local dividerX = (index - 1) * (self.mapIconWidth * 2) + self.mapPadding + self.mapIconWidth
        if index ~= #self.map and index < CUR_LEVEL - 1 then
            self:createDividerSprite(dividerX, 120)
        elseif index == CUR_LEVEL - 1 then
            self:createLoadingDivider(dividerX, 120)
        end
    end

    self.maxX = (#self.map - 1) * (self.mapIconWidth * 2)

    self.curX = (CUR_LEVEL - 1) * (self.mapIconWidth * 2)
    local startX = self.curX - self.mapIconWidth * 2
    local scrollTime = 1000
    if CUR_LEVEL == 1 then
        startX = self.maxX
        scrollTime = 3000
    end
    gfx.setDrawOffset(-startX, 0)
    local scrollToTimer = pd.timer.new(scrollTime, startX, self.curX, pd.easingFunctions.inOutCubic)
    scrollToTimer.updateCallback = function(timer)
        gfx.setDrawOffset(-timer.value, 0)
    end
    if CUR_LEVEL == 1 then
        scrollToTimer.timerEndedCallback = function()
            self.inputEnabled = true
            self:animatedSelectedSprite()
        end
    end

    local mapBackground = gfx.image.new("images/map/mapBackground")
    local mapBackgroundSprite = gfx.sprite.new(mapBackground)
    mapBackgroundSprite:setZIndex(-1000)
    mapBackgroundSprite:setCenter(0, 0.5)
    mapBackgroundSprite:moveTo(-32, 120)
    mapBackgroundSprite:add()

    local borderOffset = 16
    local mapBorder = gfx.nineSlice.new("images/map/mapBorder", 48, 48, 96, 96)
    local mapWidth = (#self.map - 1) * (self.mapIconWidth * 2) + self.mapPadding * 2
    local mapBorderImage = gfx.image.new(mapWidth + borderOffset * 2, 240 + borderOffset * 2)
    gfx.pushContext(mapBorderImage)
        mapBorder:drawInRect(0, 0, mapWidth + borderOffset * 2, 240 + borderOffset * 2)
    gfx.popContext()
    local mapBorderSprite = gfx.sprite.new(mapBorderImage)
    mapBorderSprite:setCenter(0, 0)
    mapBorderSprite:moveTo(-borderOffset, -borderOffset)
    mapBorderSprite:add()

    local levelSelectBorderImage = gfx.image.new("images/map/selectedLevelBorder")
    self.levelSelectBorderSprite = gfx.sprite.new(levelSelectBorderImage)
    self.levelSelectBorderSprite:add()
    local curSelectedSprite = self:getSelectedSprite()
    self.levelSelectBorderSprite:moveTo(curSelectedSprite.x, curSelectedSprite.y)

    self:add()
end

function MapScene:update()
    if self.inputEnabled then
        local crankChange, accelCrankChange = pd.getCrankChange()
        local newX = self.curX + crankChange
        local moveAmount = crankChange
        if newX >= self.maxX then
            moveAmount = self.maxX - self.curX
        elseif newX <= 0 then
            moveAmount = -self.curX
        end
        self.curX += moveAmount
        gfx.setDrawOffset(-self.curX, 0)

        if self:isDoubleChoice() then
            if pd.buttonJustPressed(pd.kButtonUp) or pd.buttonJustPressed(pd.kButtonDown) then
                local selectedSprite = self:getSelectedSprite()
                if self.selector == 1 then
                    selectedSprite:moveTo(selectedSprite.x, 120 - self.mapYOffset)
                    self.selector = 2
                else
                    selectedSprite:moveTo(selectedSprite.x, 120 + self.mapYOffset)
                    self.selector = 1
                end
                self:animatedSelectedSprite()
            end
        end

        if pd.buttonJustPressed(pd.kButtonA) then
            self.inputEnabled = false
            local selectedLevel = self.map[CUR_LEVEL][self.selector]
            if selectedLevel.type == "shop" then
                SceneManager:switchScene(ShopScene)
            else
                local enemyList = selectedLevel.enemies
                SceneManager:switchScene(GameScene, enemyList)
            end
        end
    end
end

function MapScene:createMapSprite(x, y, type, levelIndex)
    local iconImage
    if type == "enemy" then
        iconImage = self.skullImage
    elseif type == "elite" then
        iconImage = self.eliteImage
    elseif type == "shop" then
        iconImage = self.shopImage
    end
    local mapSprite = gfx.sprite.new(iconImage)
    if levelIndex > CUR_LEVEL then
        local ditheredIcon = gfx.image.new(iconImage:getSize())
        gfx.pushContext(ditheredIcon)
            iconImage:drawFaded(0, 0, 0.7, gfx.image.kDitherTypeBayer8x8)
        gfx.popContext()
        mapSprite:setImage(ditheredIcon)
    end
    mapSprite:moveTo(x, y)
    mapSprite:add()
    return mapSprite
end

function MapScene:loadingFinished()
    self.inputEnabled = true
    self:animatedSelectedSprite()
end

function MapScene:animatedSelectedSprite()
    if self.selectAnimator then
        self.selectAnimator:remove()
        self.selectAnimator = nil
    end

    self.selectAnimator = pd.timer.new(2000, 0, 2 * 3.14)
    self.selectAnimator.repeats = true
    local selectedSprite = self:getSelectedSprite()
    self.levelSelectBorderSprite:moveTo(selectedSprite.x, selectedSprite.y)
    self.selectAnimator.updateCallback = function(timer)
        local baseY = 120
        if self:isDoubleChoice() then
            if self.selector == 1 then
                baseY = 120 - self.mapYOffset
            else
                baseY = 120 + self.mapYOffset
            end
        end
        selectedSprite:moveTo(selectedSprite.x, math.sin(timer.value) * 5 + baseY)
    end
end

function MapScene:getSelectedSprite()
    return self.curLevelSprites[self.selector]
end

function MapScene:isDoubleChoice()
    local curLevel = self.map[CUR_LEVEL]
    return #curLevel == 2
end

function MapScene:createLoadingDivider(x, y)
    local dotDelay = 500
    local loadingDivider = gfx.sprite.new()
    loadingDivider:moveTo(x, y)
    loadingDivider:add()
    pd.timer.new(dotDelay + 500, function()
        loadingDivider:setImage(self:getDividerImage(1))
        pd.timer.new(dotDelay, function()
            loadingDivider:setImage(self:getDividerImage(2))
            pd.timer.new(dotDelay, function()
                loadingDivider:setImage(self:getDividerImage(3))
                self:loadingFinished()
            end)
        end)
    end)
end

function MapScene:createDividerSprite(x, y)
    local dividerImage = self:getDividerImage(3)
    local dividerSprite = gfx.sprite.new(dividerImage)
    dividerSprite:moveTo(x, y)
    dividerSprite:add()
end

function MapScene:getDividerImage(progress)
    local dividerImage = gfx.image.new(self.dividerWidth, 32)
    local circleDiameter, circleY = 18, 8
    local circleXPadding, circleXDistance = 8, 25
    gfx.pushContext(dividerImage)
        for i=0,progress-1 do
            gfx.fillCircleInRect(circleXPadding + circleXDistance * i, circleY, circleDiameter, circleDiameter)
        end
    gfx.popContext()
    return dividerImage
end