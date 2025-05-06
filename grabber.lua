-- From Zac Emerzian
-- Modified by Jim Lee to achieve the grab functionality

require "vector"

GrabberClass = {}

function GrabberClass:new()
  local grabber = {}
  local metadata = {__index = GrabberClass}
  setmetatable(grabber, metadata)

  grabber.previousMousePos = nil
  grabber.currentMousePos = nil

  grabber.grabPos = nil

  -- NEW: we'll want to keep track of the object (ie. card) we're holding
  grabber.heldObject = nil

  -- offset of card's position compared to grabber
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

  -- Move card if being held
  -- if self.heldObject ~= nil then
  --   self.heldObject:moveCard(self.currentMousePos.x + self.offset.x, self.currentMousePos.y + self.offset.y)
  -- end
end

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

  for _, cardPile in ipairs(cardPileTable) do
    for _, card in ipairs(cardPile.cardTable) do
      if card.state == 1 and card.faceUp then
        local pileSize = #cardPile.cardTable
        
        for j = cardPile:GetCardIndex(card), pileSize, 1 do
          table.insert(self.cardTable, cardPile.cardTable[j])
        end

        for _, selfCards in ipairs(self.cardTable) do
          cardPile:removeCard(selfCards)
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

  local validLocation = false
  for _, cardPile in ipairs(cardPileTable) do
    if self:InValidPosition(cardPile) and self:IsValidStack(cardPile) then
      for _, card in ipairs(self.cardTable) do cardPile:addCard(card) end
      for i, _ in ipairs(self.cardTable) do self.cardTable[i] = nil end
      validLocation = true
      break
    end
  end

  if not validLocation then
    for _, card in ipairs(self.cardTable) do self.previousCardPile:addCard(card) end
    for i, _ in ipairs(self.cardTable) do self.cardTable[i] = nil end
  end

  self.heldObject.state = nil
  self.heldObject = nil
  self.offset = nil
  self.grabPos = nil
end

function GrabberClass:InValidPosition(cardPile)
  if self.currentMousePos.x > cardPile.position.x and
  self.currentMousePos.x < cardPile.position.x + cardPile.interactSize.x and
  self.currentMousePos.y > cardPile.position.y and
  self.currentMousePos.y < cardPile.position.y + cardPile.interactSize.y then
    return true
  end
  return false
end

function GrabberClass:IsValidStack(cardPile)
  -- trying to place card back in old pile
  if cardPile == self.previousCardPile then
    return true
  -- if trying to place king in empty tableau pile
  elseif #cardPile.cardTable == 0 and cardPile.stack == false and self.heldObject.value == 13 then
    return true
  -- if trying to place A in foundation pile
  elseif #cardPile.cardTable == 0 and cardPile.stack == true and self.heldObject.value == 1 then
    return true
  -- if trying to place card in existing tableau pile
  elseif cardPile.stack == false and cardPile.cardTable[#cardPile.cardTable].color ~= self.heldObject.color and
  cardPile.cardTable[#cardPile.cardTable].value == self.heldObject.value+1 then
    return true
  end
  return false
end