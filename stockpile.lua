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

    for i, card in ipairs(self.stockTable) do
        card:draw()
    end

    for j, card in ipairs(self.wasteTable) do
        card:draw()
    end
end

function StockPile:addCard(card)
    card:moveCard(self.stockPilePosition.x, self.stockPilePosition.y)
    table.insert(self.stockTable, card)
end

function StockPile:drawThree()
    for i = 0, 2, 1 do
        card = table.remove(self.stockTable, 1)
        table.insert(self.wasteTable, card)
        card:moveCard(self.wastePilePosition.x, self.wastePilePosition.y * (i*20))
        card.faceUp = true
    end 
end
