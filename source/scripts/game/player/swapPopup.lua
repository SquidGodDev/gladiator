local pd <const> = playdate
local gfx <const> = playdate.graphics

class('SwapPopup').extends(gfx.sprite)

local swapAbilitiesTable

function SwapPopup:init()
    self.cellWidth = 32
    self.cellHeight = 32
    SwapPopup.super.init(self, self.cellWidth, self.cellHeight)
    self.swapAbilities = {}
    for key, item in pairs(PURCHASED_ITEMS) do
        if item.swap then
            table.insert(self.swapAbilities, item)
        end
    end
    swapAbilitiesTable = self.swapAbilities

    self.swapGrid = pd.ui.gridview.new(self.cellWidth, self.cellHeight)
    self.swapGrid:setNumberOfRows(#self.swapAbilities)
    self.swapGrid:setNumberOfColumns(1)
    self.cellPadding = 2
    self.swapGrid:setCellPadding(self.cellPadding, self.cellPadding, self.cellPadding, self.cellPadding)
    self.borderWidth = 5
    self.swapGrid:setContentInset(self.borderWidth, self.borderWidth, self.borderWidth, self.borderWidth)
    self.swapGrid.backgroundImage = gfx.nineSlice.new("images/player/swapBorder", self.borderWidth, self.borderWidth, 8, 8)

    function self.swapGrid:drawCell(section, row, column, selected, x, y, width, height)
        local abilityImagePath = swapAbilitiesTable[row].imagePath
        local abilityImage = gfx.image.new("images/shop/" .. abilityImagePath)
        abilityImage:draw(x, y)

        if selected then
            gfx.pushContext()
                gfx.setColor(gfx.kColorWhite)
                gfx.setLineWidth(2)
                gfx.drawRect(x, y, width, height)
            gfx.popContext()
        end
    end

    self:setCenter(0, 0)
    self:setZIndex(500)
    self:moveTo(350, 80)
    self:setIgnoresDrawOffset(true)
    self:setVisible(false)

    self:add()
end

function SwapPopup:update()
    if self:isVisible() then
        local crankTicks = pd.getCrankTicks(4)
        if crankTicks == 1 then
            self.swapGrid:selectNextRow(true)
        elseif crankTicks == -1 then
            self.swapGrid:selectPreviousRow(true)
        end
    end

    if self.swapGrid.needsDisplay then
        local swapGridWidth = self.cellWidth + self.borderWidth * 2 + self.cellPadding * 2
        -- local swapGridHeight = (self.cellHeight + self.cellPadding * 2) * #self.swapAbilities + self.borderWidth * 2
        local swapGridHeight = self.cellHeight * 2 + self.borderWidth * 2 + self.cellPadding * 4
        local swapGridImage = gfx.image.new(swapGridWidth, swapGridHeight)
        gfx.pushContext(swapGridImage)
            self.swapGrid:drawInRect(0, 0, swapGridWidth, swapGridHeight)
        gfx.popContext()
        self:setImage(swapGridImage)
    end
end

function SwapPopup:getSelectedItem()
    if #self.swapAbilities == 0 then
        return nil
    end
    local section, row = self.swapGrid:getSelection()
    return self.swapAbilities[row]
end