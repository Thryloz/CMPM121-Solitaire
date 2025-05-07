-- From Zac Emerzian
-- Modified by Jim Lee for Solitaire

require "vector"

CardClass = {}

CARD_STATE = {
  IDLE = 0,
  MOUSE_OVER = 1,
  GRABBED = 2
}

function CardClass:new(xPos, yPos, value, suite, faceUp)
  local card = {}
  local metadata = {__index = CardClass}
  setmetatable(card, metadata)

  card.position = Vector(xPos, yPos)
  card.size = Vector(50, 70)
  card.value = value
  if (suite == "clubs") then
    card.color = "black"
    card.suite = "clubs"
    card.suiteImage = love.graphics.newImage("Sprites/clubs.png")
  elseif (suite == "spades") then
    card.color = "black"
    card.suite = "spades"
    card.suiteImage = love.graphics.newImage("Sprites/spades.png")
  elseif (suite == "hearts") then
    card.color = "red"
    card.suite = "hearts"
    card.suiteImage = love.graphics.newImage("Sprites/hearts.png")
  elseif (suite == "diamonds") then
    card.color = "red"
    card.suite = "diamonds"
    card.suiteImage = love.graphics.newImage("Sprites/diamonds.png")
  end


  card.faceUp = faceUp

  card.state = CARD_STATE.IDLE
  return card
end

function CardClass:update()
end

function CardClass:draw()
  -- NEW: drop shadow for non-idle cards
  if self.state ~= CARD_STATE.IDLE then
    love.graphics.setColor(0, 0, 0, 0.8) -- color values [0, 1]
    local offset = 4 * (self.state == CARD_STATE.GRABBED and 2 or 1)
    love.graphics.rectangle("fill", self.position.x + offset, self.position.y + offset, self.size.x, self.size.y, 6, 6)
  end

  if self.faceUp then
    --card
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", self.position.x, self.position.y, self.size.x, self.size.y, 6, 6)
    
    --outline
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("line", self.position.x, self.position.y, self.size.x, self.size.y, 6, 6)
 
    -- number and suite
    if self.color == "red" then
      love.graphics.setColor({1, 0, 0, 1})
    else
      love.graphics.setColor({0, 0, 0, 1})
    end

    if self.value == 1 then
      love.graphics.print(tostring("A"), self.position.x + 5, self.position.y + 5)
    elseif self.value == 11 then
      love.graphics.print(tostring("J"), self.position.x + 5, self.position.y + 5)
    elseif self.value == 12 then
      love.graphics.print(tostring("Q"), self.position.x + 5, self.position.y + 5) 
    elseif self.value == 13 then
      love.graphics.print(tostring("K"), self.position.x + 5, self.position.y + 5)
    else
      love.graphics.print(tostring(tostring(self.value)), self.position.x + 5, self.position.y + 5)
    end

    -- drawing the 10 edge case
    if self.value ~= 10 then
      love.graphics.draw(self.suiteImage, self.position.x + 12.5, self.position.y + 6, 0, 0.1, 0.1)
    else
      love.graphics.draw(self.suiteImage, self.position.x + 20, self.position.y + 6, 0, 0.1, 0.1)
    end

  else
    -- back of card
    love.graphics.setColor(0, 0, 1, 1)
    love.graphics.rectangle("fill", self.position.x, self.position.y, self.size.x, self.size.y, 6, 6)
    
    -- outline
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("line", self.position.x, self.position.y, self.size.x, self.size.y, 6, 6)
  end
end

function CardClass:checkForMouseOver(grabber)
  if self.state == CARD_STATE.GRABBED then
    return
  end

  local mousePos = grabber.currentMousePos
  local isMouseOver = 
    mousePos.x > self.position.x and
    mousePos.x < self.position.x + self.size.x and
    mousePos.y > self.position.y and
    mousePos.y < self.position.y + self.size.y

  self.state = isMouseOver and CARD_STATE.MOUSE_OVER or CARD_STATE.IDLE
end

function CardClass:moveCard(xPos, yPos)
    self.position.x = xPos
    self.position.y = yPos
end



