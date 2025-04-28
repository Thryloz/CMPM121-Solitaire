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

function GrabberClass:update()
  self.currentMousePos = Vector(
    love.mouse.getX(),
    love.mouse.getY()
  )

  -- grabbing card in pile
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
  self.heldObject = card
  self.offset = card.position - self.grabPos
  self.heldObject.state = 2 -- object (card) is grabbed
end

function GrabberClass:release()
  -- NEW: some more logic stubs here
  if self.heldObject == nil then -- we have nothing to release
    return
  end  
end