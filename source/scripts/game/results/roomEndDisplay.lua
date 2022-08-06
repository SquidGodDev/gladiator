import "scripts/map/mapScene"

local pd <const> = playdate
local gfx <const> = playdate.graphics

class('RoomEndDisplay').extends(gfx.sprite)

function RoomEndDisplay:init()
    self.dialogWidth = 240
    self.dialogHeight = 140
    self.leftPadding = 30

    self.borderWidth = 3
    self.cornerRadius = 3

    self:setZIndex(2000)

    local dialogImage = gfx.image.new(self.dialogWidth, self.dialogHeight)
    gfx.pushContext(dialogImage)
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRoundRect(0, 0, self.dialogWidth, self.dialogHeight, self.cornerRadius)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRoundRect(self.borderWidth, self.borderWidth, self.dialogWidth - self.borderWidth * 2, self.dialogHeight  - self.borderWidth * 2, self.cornerRadius)
        gfx.setColor(gfx.kColorBlack)
        gfx.drawTextAligned("*LEVEL CLEARED!*", self.dialogWidth / 2, 10, kTextAlignment.center)
        local goldEarned = 50
        GOLD += goldEarned
        gfx.drawText("Gold Earned: " .. goldEarned, self.leftPadding, 45)
        -- gfx.drawText(maxHeightScoreText, self.leftPadding, 75)
        gfx.drawTextAligned("_Press_ *A* _to continue_", self.dialogWidth / 2, 110, kTextAlignment.center)
    gfx.popContext()
    self:setImage(dialogImage)

    self.animateDuration = 500
    self.moveStart = -self.dialogHeight / 2
    self.moveEnd = 120
    self:moveTo(200, self.moveStart)

    self.moveAnimator = gfx.animator.new(self.animateDuration, self.moveStart, self.moveEnd, pd.easingFunctions.inOutCubic)

    self:setIgnoresDrawOffset(true)
    self:add()
end

function RoomEndDisplay:update()
    if self.moveAnimator then
        self:moveTo(200, self.moveAnimator:currentValue())
        if self.moveAnimator:ended() then
            self.moveAnimator = nil
        end
    else
        if pd.buttonJustPressed(pd.kButtonA) then
            SceneManager:switchScene(MapScene)
        end
    end
end