import "scripts/map/mapScene"

local pd <const> = playdate
local gfx <const> = playdate.graphics

local shopItems = {
    {
        name = "Bomb",
        path = "bomb"
    },
    {
        name = "Bow and Arrow",
        path = "bow"
    },
    {
        name = "Crown",
        path = "crown"
    },
    {
        name = "Potion",
        path = "potion"
    },
    {
        name = "Queen of Hearts",
        path = "queenOfHearts"
    },
    {
        name = "Wooden Shield",
        path = "woodenShield"
    }
}

class('ShopScene').extends(gfx.sprite)

function ShopScene:init()
    self.cellWidth = 42
    self.cellHeight = 42
    self.shopGridview = pd.ui.gridview.new(self.cellWidth, self.cellHeight)
    self.cellPadding = 2
    self.shopGridview:setCellPadding(0, self.cellPadding, 0, 0)

    self.shopGridview:setNumberOfRows(1)
    self.shopGridview:setNumberOfColumns(#shopItems)

    function self.shopGridview:drawCell(section, row, column, selected, x, y, width, height)
        local shopItemBorder = gfx.image.new("images/shop/shopItemBorder")
        shopItemBorder:draw(x, y)

        if selected then
            local shopSelectBorder = gfx.image.new("images/shop/shopSelectBorder")
            shopSelectBorder:draw(x, y)
        end
        -- local fontHeight = gfx.getSystemFont():getHeight()
        -- gfx.drawTextInRect(fruits[row], x, y + (height/2 - fontHeight/2) + 2, width, height, nil, nil, kTextAlignment.center)
        local itemImagePath = shopItems[column].path
        local itemImage = gfx.image.new("images/shop/" .. itemImagePath)
        itemImage:draw(x + 5, y + 5)
    end

    self.shopItemsSprite = gfx.sprite.new()
    self.shopItemsSprite:setCenter(0, 0)
    self.shopItemsSprite:moveTo(30, 180)
    self.shopItemsSprite:add()

    self.finishedShopping = false

    self:add()
end

function ShopScene:update()
    if pd.buttonJustPressed(pd.kButtonA) and not self.finishedShopping then
        self.finishedShopping = true
        CUR_LEVEL += 1
        SceneManager:switchScene(MapScene)
    end

    if pd.buttonJustPressed(pd.kButtonLeft) then
        self.shopGridview:selectPreviousColumn(true)
    elseif pd.buttonJustPressed(pd.kButtonRight) then
        self.shopGridview:selectNextColumn(true)
    end

    local crankTicks = pd.getCrankTicks(2)
    if crankTicks == 1 then
        self.shopGridview:selectNextColumn(true)
    elseif crankTicks == -1 then
        self.shopGridview:selectPreviousColumn(true)
    end

    if self.shopGridview.needsDisplay then
        local gridviewWidth = #shopItems * (self.cellPadding + self.cellWidth)
        local gridviewImage = gfx.image.new(gridviewWidth, self.cellHeight)
        gfx.pushContext(gridviewImage)
            self.shopGridview:drawInRect(0, 0, gridviewWidth, self.cellHeight)
        gfx.popContext()
        self.shopItemsSprite:setImage(gridviewImage)
    end
end
