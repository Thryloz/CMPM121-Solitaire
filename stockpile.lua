require "vector"

StockPile = {}

function StockPile:new(xPos, yPos)
    local stockPile = {}
    setmetatable(stockPile, {__index = StockPile})

    stockPile.stockPilePosition = Vector(xPos, yPos)
    stockPile.wastePilePosition = Vector(xPos, yPos + 100)
    stockPile.size = Vector(50, 70)
    stockPile.interactSize = Vector(55, 75)

    stockPile.stockTable = {}
    stockPile.wasteTable = {}
    
    return stockPile
end

function StockPile:draw()
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", self.stockPilePosition.x, self.stockPilePosition.y, self.size.x, self.size.y, 6, 6)
    love.graphics.rectangle("fill", self.wastePilePosition.x , self.wastePilePosition.y, self.size.x, self.size.y, 6, 6)

    for _, card in ipairs(self.stockTable) do
        card:moveCard(self.stockPilePosition.x, self.stockPilePosition.y)
        card.faceUp = false
        card:draw()
    end

    if #self.wasteTable ~= 0 then
        if #self.wasteTable >= 3 then
            for i = 2, 0, -1 do
                local card = stockPile.wasteTable[#stockPile.wasteTable - i]
                card:moveCard(self.wastePilePosition.x, self.wastePilePosition.y + ((2-i)*20))
                card.faceUp = true
                card:draw()
            end
        else
            for _, card in ipairs(stockPile.wasteTable) do card:draw() end
        end
    end
end

function StockPile:addCard(card)
    card:moveCard(self.stockPilePosition.x, self.stockPilePosition.y)
    table.insert(self.stockTable, card)
end

function StockPile:drawThree()
    -- if stock table is empty reset it
    if #self.stockTable == 0 then
        for _, card in ipairs(self.wasteTable) do table.insert(self.stockTable, card) end
        for i, _ in ipairs(self.wasteTable) do self.wasteTable[i] = nil end
        return
    end

    for _ = 0, 2, 1 do
        local card = table.remove(self.stockTable, 1)
        if card ~= nil then table.insert(self.wasteTable, card) end
    end
end
