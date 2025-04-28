require "vector"

StockPile = {}

function StockPile:new(xPos, yPos)
    local drawPile = {}
    setmetatable(drawPile, {__index = StockPile})

    drawPile.stockPilePosition = Vector(xPos, yPos)
    drawPile.wastePilePosition = Vector(xPos, yPos + 100)
    drawPile.size = Vector(50, 70)
    drawPile.interactSize = Vector(55, 75)

    drawPile.stockTable = {}
    drawPile.wasteTable = {}
    
    return drawPile
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
    card1 = table.remove(self.stockTable, 1)
    card2 = table.remove(self.stockTable, 1)
    card3 = table.remove(self.stockTable, 1)

    table.insert(self.wasteTable, card1)
    table.insert(self.wasteTable, card2)
    table.insert(self.wasteTable, card3)

    card1.faceUp = true
    card2.faceUp = true
    card3.faceUp = true

    card1.moveCard(self.wastePilePosition.x, self.wastePilePosition.y)
    card2.moveCard(self.wastePilePosition, self.wastePilePosition.y)
    card3.moveCard(self.wastePilePosition, self.wastePilePosition.y)
end
