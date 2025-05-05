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
  if self.heldObject ~= nil then
    self.heldObject:moveCard(self.currentMousePos.x + self.offset.x, self.currentMousePos.y + self.offset.y)
  end
end


function GrabberClass:grab()
  self.grabPos = self.currentMousePos

  for _, cardPile in ipairs(cardPileTable) do
    for i, card in ipairs(cardPile.cardTable) do
      if card.state == 1 and card.faceUp then
        table.insert(cardTable, card)
        cardPile:removeCard(card)
        self.heldObject = card
        self.offset = card.position - self.grabPos
        self.previousCardPile = cardPile
        self.heldObject.state = 2 -- object (card) is grabbed
      end
    end
  end
end

function GrabberClass:release()
  -- NEW: some more logic stubs here
  if self.heldObject == nil then -- we have nothing to release
      self.offset = nil
      self.grabPos = nil
    return
  end

  local validLocation = false
  for _, cardPile in ipairs(cardPileTable) do
    -- position check
    if self:InValidPositionInValidPosition(cardPile) then
    if #cardPile.cardTable == 0 then
      cardPile:addCard(self.heldObject)
      table.remove(cardTable, 1)
      validLocation = true
      break
    elseif cardPile.cardTable[#cardPile.cardTable].color ~= self.heldObject.color and
    cardPile.cardTable[#cardPile.cardTable].value == self.heldObject.value+1 then
      cardPile:addCard(self.heldObject)
      table.remove(cardTable, 1)
      validLocation = true
      break
    end
    end
  end

  if not validLocation then
    self.heldObject:moveCard(self.grabPos.x + self.offset.x, self.grabPos.y + self.offset.y)
    self.previousCardPile:addCard(self.heldObject)
    table.remove(cardTable, 1)
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
end
