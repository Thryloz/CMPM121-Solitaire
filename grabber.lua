-- From Zac Emerzian
-- Modified by Jim Lee to achieve the grab functionality

require "vector"

GrabberClass = {}

function GrabberClass:new()
  local grabber = {}
  local metadata = {__index = GrabberClass}
  setmetatable(grabber, metadata)

  grabber.currentMousePos = nil
  grabber.grabPos = nil
  grabber.heldObject = nil
  grabber.offset = nil
  grabber.previousCardPile = nil
  grabber.cardTable = {}

  return grabber
end

function GrabberClass:update()
  self.currentMousePos = Vector(
    love.mouse.getX(),
    love.mouse.getY()
  )

  -- Grab card
  if love.mouse.isDown(1) and self.grabPos == nil then
    self:grab()
  end

  -- Release
  if not love.mouse.isDown(1) and self.grabPos ~= nil then
    self:release()
  end
end

-- draw cards in grabber's hand
function GrabberClass:draw()
  if (#self.cardTable ~= 0) then
    for i, card in ipairs(self.cardTable) do
      card:moveCard(self.currentMousePos.x + self.offset.x, self.currentMousePos.y + self.offset.y + ((i-1) * 20))
      card:draw()
    end
  end
end

function GrabberClass:grab()
  self.grabPos = self.currentMousePos

  -- draw 3 from stock pile
  if self.grabPos.x > stockPile.stockPilePosition.x and 
  self.grabPos.x < stockPile.stockPilePosition.x + stockPile.interactSize.x and
  self.grabPos.y > stockPile.stockPilePosition.y and
  self.grabPos.y < stockPile.stockPilePosition.y + stockPile.interactSize.y then
    stockPile:drawThree();
    return
  end

  -- grabbing cards from waste pile
  local lastCardWastePile = stockPile.wasteTable[#stockPile.wasteTable]
  if lastCardWastePile ~= nil and self.grabPos.x > lastCardWastePile.position.x and
  self.grabPos.x < lastCardWastePile.position.x + lastCardWastePile.size.x and
  self.grabPos.y > lastCardWastePile.position.y and
  self.grabPos.y < lastCardWastePile.position.y + lastCardWastePile.size.y then
    table.insert(self.cardTable, lastCardWastePile)
    table.remove(stockPile.wasteTable, #stockPile.wasteTable)
    self.heldObject = lastCardWastePile
    self.offset = lastCardWastePile.position - self.grabPos
    self.previousCardPile = stockPile.wasteTable
    self.heldObject.state = 2
    return
  end

  for _, cardPile in ipairs(cardPileTable) do
    for _, card in ipairs(cardPile.cardTable) do
      if card.state == 1 and card.faceUp then
        -- grabbing 1 card from foundation pile
        if cardPile.stack == true then
          table.insert(self.cardTable, card)
          cardPile:removeCard(card)
        else
        -- grabbing cards from tableau piles
          local pileSize = #cardPile.cardTable

          for j = cardPile:GetCardIndex(card), pileSize, 1 do
            table.insert(self.cardTable, cardPile.cardTable[j])
          end

          for _, selfCards in ipairs(self.cardTable) do
            cardPile:removeCard(selfCards)
          end
        end

        self.heldObject = card
        self.offset = card.position - self.grabPos
        self.previousCardPile = cardPile
        self.heldObject.state = 2
        break
      end
    end
  end
end

function GrabberClass:release()
  if self.heldObject == nil then -- we have nothing to release
      self.offset = nil
      self.grabPos = nil
    return
  end

  -- if valid location, add all cards in grabber cardtable to pile and clears grabber cardpile
  local validLocation = false
  for _, cardPile in ipairs(cardPileTable) do
    if self:InValidPosition(cardPile) and self:IsValidStack(cardPile) then
      for _, card in ipairs(self.cardTable) do cardPile:addCard(card) end
      for i, _ in ipairs(self.cardTable) do self.cardTable[i] = nil end
      validLocation = true
      break
    end
  end

  -- if not valid, add all cards in grabber cardtable to previous pile and clears grabber cardtable
  if not validLocation then
    if self.previousCardPile ~= stockPile.wasteTable then
      for _, card in ipairs(self.cardTable) do self.previousCardPile:addCard(card) end
      for i, _ in ipairs(self.cardTable) do self.cardTable[i] = nil end
    else
      table.insert(stockPile.wasteTable, self.heldObject)
      self.heldObject:moveCard(self.grabPos.x + self.offset.x, self.grabPos.y + self.offset.y)
      self.cardTable[1] = nil
    end
  end

  self.heldObject.state = nil
  self.heldObject = nil
  self.offset = nil
  self.grabPos = nil
end

-- helper function to see if mouse is in a valid cardpile location
function GrabberClass:InValidPosition(cardPile)
  if self.currentMousePos.x > cardPile.position.x and
  self.currentMousePos.x < cardPile.position.x + cardPile.interactSize.x and
  self.currentMousePos.y > cardPile.position.y and
  self.currentMousePos.y < cardPile.position.y + cardPile.interactSize.y then
    return true
  end
  return false
end

-- helper function checking solitaire rules
function GrabberClass:IsValidStack(cardPile)
  -- if trying to place card back in old pile
  if cardPile == self.previousCardPile then
    return true
  -- if trying to place king in empty tableau pile
  elseif cardPile.stack == false and #cardPile.cardTable == 0 and self.heldObject.value == 13 then
    return true
  -- if trying to place card in existing tableau pile
  elseif cardPile.stack == false and cardPile.cardTable[#cardPile.cardTable].color ~= self.heldObject.color and
  cardPile.cardTable[#cardPile.cardTable].value == self.heldObject.value+1 then
    return true
  -- if trying to place A in foundation pile
  elseif cardPile.stack == true and #cardPile.cardTable == 0 and self.heldObject.value == 1 then
    return true
  -- if trying to place in foundation pile
  elseif cardPile.stack == true and #self.cardTable == 1 and
  cardPile.cardTable[#cardPile.cardTable].value == self.heldObject.value-1 and
  cardPile.cardTable[#cardPile.cardTable].suite == self.heldObject.suite then
    return true
  end
  return false
end