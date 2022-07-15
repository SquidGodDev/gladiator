import "scripts/game/gameScene"

local pd <const> = playdate
local gfx <const> = playdate.graphics

class('ResultsScene').extends(gfx.sprite)

function ResultsScene:init()
    local curWaveText = "Wave Reached: " .. CUR_WAVE
    if CUR_WAVE > MAX_WAVE then
        MAX_WAVE = CUR_WAVE
        curWaveText = curWaveText .. " - *NEW*"
    end
    local maxWaveText = "Max Wave Reached: " .. MAX_WAVE

    self:createTextSprite(curWaveText, 200, 70)
    self:createTextSprite(maxWaveText, 200, 110)

    local promptText = "Press A to Restart"
    self:createTextSprite(promptText, 200, 190)

    self:add()
end

function ResultsScene:update()
    if pd.buttonJustPressed(pd.kButtonA) then
        SceneManager:switchScene(GameScene)
    end
end

function ResultsScene:createTextSprite(text, x, y)
    local textSprite = gfx.sprite.new(gfx.getTextSize(text))
    local textImage = gfx.image.new(gfx.getTextSize(text))
    gfx.pushContext(textImage)
        gfx.drawText(text, 0, 0)
    gfx.popContext()
    textSprite:setImage(textImage)
    textSprite:moveTo(x, y)
    textSprite:add()
end