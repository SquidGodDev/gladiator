-- There's not much to this, just another gridview basically

import "scripts/map/mapScene"

local pd <const> = playdate
local gfx <const> = playdate.graphics

local availableItems = json.decodeFile("items.json")
local shopItems

class('ShopScene').extends(gfx.sprite)

function ShopScene:init()
    self.shopItemKeys = {}
    self:generateShopItems()

    self.cellWidth = 42
    self.cellHeight = 42
    self.shopGridview = pd.ui.gridview.new(self.cellWidth, self.cellHeight)
    self.cellPadding = 2
    self.shopGridview:setCellPadding(0, self.cellPadding, 0, 0)

    self.shopGridview:setNumberOfRows(1)
    self.shopGridview:setNumberOfColumns(#shopItems)

    self.gridRedraw = false

    function self.shopGridview:drawCell(section, row, column, selected, x, y, width, height)
        local shopItemBorder = gfx.image.new("images/shop/shopItemBorder")
        shopItemBorder:draw(x, y)

        if selected then
            local shopSelectBorder = gfx.image.new("images/shop/shopSelectBorder")
            shopSelectBorder:draw(x, y)
        end

        local itemImagePath = shopItems[column].imagePath
        local itemImage = gfx.image.new("images/shop/" .. itemImagePath)
        if shopItems[column].purchased then
            local ditheredItemImage = gfx.image.new(itemImage:getSize())
            gfx.pushContext(ditheredItemImage)
                itemImage:drawFaded(0, 0, 0.3, gfx.image.kDitherTypeBayer8x8)
            gfx.popContext()
            itemImage = ditheredItemImage
        end
        itemImage:draw(x + 5, y + 5)
        if shopItems[column].purchased then
            local xImage = gfx.image.new("images/shop/X")
            xImage:draw(x + 5, y + 5)
        end
    end

    self.shopItemsSprite = gfx.sprite.new()
    self.shopItemsSprite:setCenter(0, 0)
    self.shopItemsSprite:moveTo(30, 180)
    self.shopItemsSprite:add()

    self.finishedShopping = false

    self.itemDisplaySprite = gfx.sprite.new()
    self.itemDisplaySprite:setCenter(0, 0)
    self.itemDisplaySprite:moveTo(40, 10)
    self.itemDisplaySprite:add()

    self:updateItemDisplay()

    self.goldSprite = gfx.sprite.new()
    self.goldSprite:moveTo(350, 200)
    self.goldSprite:add()

    self:updateGoldDisplay()

    local shopKeeperImageTable = gfx.imagetable.new("images/shop/shopKeeper-table-100-100")
    self.shopKeeper = gfx.animation.loop.new(200, shopKeeperImageTable, true)
    self.shopKeeperSprite = gfx.sprite.new()
    self.shopKeeperSprite:moveTo(340, 90)
    self.shopKeeperSprite:add()

    self:add()
end

function ShopScene:update()

    self:drawShopkeeper()

    if pd.buttonJustPressed(pd.kButtonB) and not self.finishedShopping then
        self.finishedShopping = true
        CUR_LEVEL += 1
        SceneManager:switchScene(MapScene)
    end

    if pd.buttonIsPressed(pd.kButtonA) then
        local section, row, column = self.shopGridview:getSelection()
        local selectedItem = shopItems[column]
        if not selectedItem.purchased then
            if selectedItem.cost <= GOLD then
                GOLD -= selectedItem.cost
                selectedItem.purchased = true
                self.gridRedraw = true
                PURCHASED_ITEMS[self.shopItemKeys[column]] = selectedItem
                self:updateGoldDisplay()
                self:updateItemDisplay()
            else
                -- Error sfx
            end
        end
    end

    if pd.buttonJustPressed(pd.kButtonLeft) then
        self.shopGridview:selectPreviousColumn(true)
        self:updateItemDisplay()
    elseif pd.buttonJustPressed(pd.kButtonRight) then
        self.shopGridview:selectNextColumn(true)
        self:updateItemDisplay()
    end

    local crankTicks = pd.getCrankTicks(2)
    if crankTicks == 1 then
        self.shopGridview:selectNextColumn(true)
        self:updateItemDisplay()
    elseif crankTicks == -1 then
        self.shopGridview:selectPreviousColumn(true)
        self:updateItemDisplay()
    end

    if self.shopGridview.needsDisplay or self.gridRedraw then
        self.gridRedraw = false
        local gridviewWidth = #shopItems * (self.cellPadding + self.cellWidth)
        local gridviewImage = gfx.image.new(gridviewWidth, self.cellHeight)
        gfx.pushContext(gridviewImage)
            self.shopGridview:drawInRect(0, 0, gridviewWidth, self.cellHeight)
        gfx.popContext()
        self.shopItemsSprite:setImage(gridviewImage)
    end
end

function ShopScene:updateItemDisplay()
    local displayWidth = 240
    local displayHeight = 180
    local section, row, column = self.shopGridview:getSelection()
    local selectedItem = shopItems[column]
    local itemDisplayImage = gfx.image.new(displayWidth, displayHeight)
    gfx.pushContext(itemDisplayImage)
        local itemImage = gfx.image.new("images/shop/" .. selectedItem.imagePath)
        itemImage:drawAnchored(displayWidth / 2, 20, 0.5, 0.5)
        if selectedItem.purchased then
            gfx.drawTextAligned("*_Purchased!_*", displayWidth / 2, 50, kTextAlignment.center)
        else
            gfx.drawTextAligned("*" .. selectedItem.name .. "*", displayWidth / 2, 50, kTextAlignment.center)
        end
        gfx.drawTextInRect(selectedItem.description, 0, 80, displayWidth, 60)
        gfx.drawTextAligned("*" .. selectedItem.cost .. "*", displayWidth / 2, 140, kTextAlignment.center)
    gfx.popContext()
    self.itemDisplaySprite:setImage(itemDisplayImage)
end

function ShopScene:generateShopItems()
    shopItems = {}
    for itemKey, value in pairs(availableItems) do
        if not PURCHASED_ITEMS[itemKey] then
            table.insert(shopItems, value)
            table.insert(self.shopItemKeys, itemKey)
        end
    end
end

function ShopScene:updateGoldDisplay()
    local goldText = "Gold: " .. GOLD
    local goldTextImage = gfx.image.new(gfx.getTextSize(goldText))
    gfx.pushContext(goldTextImage)
        gfx.drawText(goldText, 0, 0)
    gfx.popContext()
    self.goldSprite:setImage(goldTextImage)
end

function ShopScene:drawShopkeeper()
    local shopKeeperImage = gfx.image.new(100, 100)
    gfx.pushContext(shopKeeperImage)
        self.shopKeeper:draw(0, 0)
    gfx.popContext()
    self.shopKeeperSprite:setImage(shopKeeperImage)
end