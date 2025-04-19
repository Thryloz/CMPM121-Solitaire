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

  return grabber
end

function GrabberClass:update(cardTable, cardPileTable)
  self.currentMousePos = Vector(
    love.mouse.getX(),
    love.mouse.getY()
  )


  -- grabbing card in pile
  if love.mouse.isDown(1) and self.grabPos == nil then
    for i, cardPile in ipairs(cardPileTable) do
      if self.currentMousePos.x > cardPile.position.x and
      self.currentMousePos.x < cardPile.position.x + cardPile.interactSize.x and
      self.currentMousePos.y > cardPile.position.y and
      self.currentMousePos.y < cardPile.position.y + cardPile.interactSize.y 
      and #cardPile.cardTable ~= 0
      then
        local bottomCard = cardPile.cardTable[#cardPile.cardTable]
        if bottomCard.state == 1 and #cardPile.cardTable ~= 0 then
          table.insert(cardTable, bottomCard)
          cardPile:removeCard(bottomCard)
          self:grab(cardTable[#cardTable])
        end
        break
      end
    end
  end

  -- grabbing movable card
  -- Click (just the first frame)
  if love.mouse.isDown(1) and self.grabPos == nil then
    for _, card in ipairs(cardTable) do
        if (card.state == 1) and (card.faceUp == true) then
            self:grab(card)
            break
        end
    end
  end

  -- Release
  if not love.mouse.isDown(1) and self.grabPos ~= nil then
    self:release(cardTable, cardPileTable)
  end

  -- Move card if being held
  if self.heldObject ~= nil then
    self.heldObject:moveCard(self.currentMousePos.x + self.offset.x, self.currentMousePos.y + self.offset.y)
  end
end


function GrabberClass:grab(card)
  self.grabPos = self.currentMousePos
  self.heldObject = card
  self.offset = card.position - self.grabPos
  self.heldObject.state = 2 -- object (card) is grabbed
end

function GrabberClass:release(cardTable, cardPileTable)
  -- NEW: some more logic stubs here
  if self.heldObject == nil then -- we have nothing to release
    return
  end

  local cardPlacedInTable = false
  -- place card in pile
  for _, cardPile in ipairs(cardPileTable) do
    if self.heldObject.position.x + self.heldObject.size.x/2 > cardPile.position.x and
    self.heldObject.position.x + self.heldObject.size.x/2 < cardPile.position.x + cardPile.interactSize.x and
    self.heldObject.position.y + self.heldObject.size.y/2 > cardPile.position.y and
    self.heldObject.position.y + self.heldObject.size.y/2 < cardPile.position.y + cardPile.interactSize.y then
      
      -- add card to pile
      cardPile:addCard(self.heldObject)

      -- remove card from general table
      for i, card in ipairs(cardTable) do
        if card.value == self.heldObject.value and card.suite == self.heldObject.suite then
          table.remove(cardTable, i)
          break
        end
      end

    cardPlacedInTable = true
    end
  end

  -- if card wasn't placed in table, put it in general table
  if not cardPlacedInTable then
    table.insert(cardTable, self.heldObject)
    for _, cardPile in ipairs(cardPileTable) do
      cardPile:removeCard(self.heldObject)
    end
  end

  self.heldObject.state = 0 -- it's no longer grabbed

  self.heldObject = nil
  self.offset = nil
  self.grabPos = nil
end