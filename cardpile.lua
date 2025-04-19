-- Jim Lee

require "vector"

CardPile = {}

function CardPile:new(xPos, yPos, drawStack, stack)
  local cardPile = {}
  local metadata = {__index = CardPile}
  setmetatable(cardPile, metadata)

  cardPile.position = Vector(xPos, yPos)
  cardPile.size = Vector(50, 70)
  cardPile.interactSize = Vector(55, 75)
  cardPile.drawStack = drawStack
  cardPile.stack = stack
  cardPile.cardTable = {}

  return cardPile
end

function CardPile:update()
  if not self.drawStack and #self.cardTable ~= 0 and self.cardTable[#self.cardTable].faceUp == false then
    self.cardTable[#self.cardTable].faceUp = true
  end
end

function CardPile:draw()
  love.graphics.setColor(0, 0, 0, 0.5)
  love.graphics.rectangle("fill", self.position.x, self.position.y, self.size.x, self.size.y, 6, 6)

  if #self.cardTable > 0 then
    for i, card in ipairs(self.cardTable) do
      if self.stack then
        card:moveCard(self.position.x, self.position.y)
        card:draw()
      else
        card:moveCard(self.position.x, self.position.y + ((i-1) * 20))
        card:draw()
      end
    end
  end
end

function CardPile:addCard(card)
  table.insert(self.cardTable, card)
  if not self.stack then
    self.interactSize = Vector(self.interactSize.x, self.interactSize.y + 20)
  end

  print("--------")
  for _, j in ipairs(self.cardTable) do
    print("card: " ..tostring(j.value))
  end
end

function CardPile:removeCard(card)
  for i, ownCard in ipairs(self.cardTable) do
    if card.value == ownCard.value and card.suite == ownCard.suite then
      table.remove(self.cardTable, i)
      if not self.stack then
        self.interactSize = Vector(self.interactSize.x, self.interactSize.y - 20)
      end
      break
    end
  end
end
