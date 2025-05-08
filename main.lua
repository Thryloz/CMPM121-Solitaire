-- Jim Lee
-- CMPM 121 - Solitaire
-- 4-7-2025
io.stdout:setvbuf("no")

require("card")
require("grabber")
require("stockpile")
require("cardpile")

resetButton = {
  posX = 50,
  posY = 400,
  sizeX = 60,
  sizeY = 30
}

SCREEN_WIDTH = 960
SCREEN_HEIGHT = 640

function love.load()
  cardPool = {
    CardClass:new(100, 100, 1, "clubs", false),
    CardClass:new(100, 100, 2, "clubs", false),
    CardClass:new(100, 100, 3, "clubs", false),
    CardClass:new(100, 100, 4, "clubs", false),
    CardClass:new(100, 100, 5, "clubs", false),
    CardClass:new(100, 100, 6, "clubs", false),
    CardClass:new(100, 100, 7, "clubs", false),
    CardClass:new(100, 100, 8, "clubs", false),
    CardClass:new(100, 100, 9, "clubs", false),
    CardClass:new(100, 100, 10, "clubs", false),
    CardClass:new(100, 100, 11, "clubs", false),
    CardClass:new(100, 100, 12, "clubs", false),
    CardClass:new(100, 100, 13, "clubs", false),
    CardClass:new(100, 100, 1, "spades", false),
    CardClass:new(100, 100, 2, "spades", false),
    CardClass:new(100, 100, 3, "spades", false),
    CardClass:new(100, 100, 4, "spades", false),
    CardClass:new(100, 100, 5, "spades", false),
    CardClass:new(100, 100, 6, "spades", false),
    CardClass:new(100, 100, 7, "spades", false),
    CardClass:new(100, 100, 8, "spades", false),
    CardClass:new(100, 100, 9, "spades", false),
    CardClass:new(100, 100, 10, "spades", false),
    CardClass:new(100, 100, 11, "spades", false),
    CardClass:new(100, 100, 12, "spades", false),
    CardClass:new(100, 100, 13, "spades", false),
    CardClass:new(100, 100, 1, "hearts", false),
    CardClass:new(100, 100, 2, "hearts", false),
    CardClass:new(100, 100, 3, "hearts", false),
    CardClass:new(100, 100, 4, "hearts", false),
    CardClass:new(100, 100, 5, "hearts", false),
    CardClass:new(100, 100, 6, "hearts", false),
    CardClass:new(100, 100, 7, "hearts", false),
    CardClass:new(100, 100, 8, "hearts", false),
    CardClass:new(100, 100, 9, "hearts", false),
    CardClass:new(100, 100, 10, "hearts", false),
    CardClass:new(100, 100, 11, "hearts", false),
    CardClass:new(100, 100, 12, "hearts", false),
    CardClass:new(100, 100, 13, "hearts", false),
    CardClass:new(100, 100, 1, "diamonds", false),
    CardClass:new(100, 100, 2, "diamonds", false),
    CardClass:new(100, 100, 3, "diamonds", false),
    CardClass:new(100, 100, 4, "diamonds", false),
    CardClass:new(100, 100, 5, "diamonds", false),
    CardClass:new(100, 100, 6, "diamonds", false),
    CardClass:new(100, 100, 7, "diamonds", false),
    CardClass:new(100, 100, 8, "diamonds", false),
    CardClass:new(100, 100, 9, "diamonds", false),
    CardClass:new(100, 100, 10, "diamonds", false),
    CardClass:new(100, 100, 11, "diamonds", false),
    CardClass:new(100, 100, 12, "diamonds", false),
    CardClass:new(100, 100, 13, "diamonds", false),
  }
  love.window.setTitle("Solitaire'nt")
  love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT)
  love.graphics.setBackgroundColor(0, 0.7, 0.2, 1)
  math.randomseed(os.time())

  grabber = GrabberClass:new()
  cardPileTable = {}
  stockPile = StockPile:new(50, 50)

  -- tableau piles
  for i = 0, 6, 1 do
    table.insert(cardPileTable, CardPile:new (200 + (i*75), 50, false))
  end

  -- in play cards
  for i = 0, 6, 1 do
    for j = 0, i, 1 do
      local index = math.random(1, #cardPool)
      local card = cardPool[index]

      -- only flip the first card up 
      if j == 0 and i == 0 then
        card.faceUp = true
        else if j == i then
          card.faceUp = true
        end
      end

      -- add to pile
      local chosenPile = cardPileTable[i+1]
      chosenPile:addCard(card)
      table.remove(cardPool, index)
    end
  end


  -- add rest of cards to draw pile
  while #cardPool > 0 do
    local randIndex = math.random(1, #cardPool)
    stockPile:addCard(cardPool[randIndex])
    table.remove(cardPool, randIndex)
  end

  -- foundation piles
  table.insert(cardPileTable, CardPile:new(800, 50, true))
  table.insert(cardPileTable, CardPile:new(800, 150, true))
  table.insert(cardPileTable, CardPile:new(800, 250, true))
  table.insert(cardPileTable, CardPile:new(800, 350, true))

  gameState = "playing"
end

function love.update()
  grabber:update()
  checkForMouseMoving()
  for _, cardPile in ipairs(cardPileTable) do
    cardPile:update()
  end

  -- check win 
  local stack1 = false
  local stack2 = false
  local stack3 = false
  local stack4 = false
  if #cardPileTable[#cardPileTable].cardTable == 13 then stack1 = true end
  if #cardPileTable[#cardPileTable-1].cardTable == 13 then stack2 = true end
  if #cardPileTable[#cardPileTable-2].cardTable == 13 then stack3 = true end
  if #cardPileTable[#cardPileTable-3].cardTable == 13 then stack4 = true end
  if stack1 and stack2 and stack3 and stack4 then
    gameState = "win"
  end
end

function love.draw()
  if gameState == "win" then
    love.graphics.setFont(love.graphics.newFont(34))
    love.graphics.setBackgroundColor(0.01, 0.27, 0.16, 1)
    love.graphics.print("You Win!", SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 0, 1, 1, 78, 78)
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.setColor(0, 0, 0, .5)
    love.graphics.rectangle("fill", resetButton.posX, resetButton.posY, resetButton.sizeX, resetButton.sizeY, 6, 6)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Reset", resetButton.posX + resetButton.sizeX/5, resetButton.posY + resetButton.sizeY/5)
    return
  end
  love.graphics.setColor(0, 0, 0, .5)
  love.graphics.rectangle("fill", resetButton.posX, resetButton.posY, resetButton.sizeX, resetButton.sizeY, 6, 6)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print("Reset", resetButton.posX + resetButton.sizeX/5, resetButton.posY + resetButton.sizeY/5)

  stockPile:draw()
  for _, cardPile in ipairs(cardPileTable) do
    cardPile:draw()
  end
  grabber:draw()
end

function checkForMouseMoving()
  if grabber.currentMousePos == nil then return end

  for _, cardPile in ipairs(cardPileTable) do
    for _, card in ipairs(cardPile.cardTable) do
      card:checkForMouseOver(grabber)
    end
  end

  for _, card in ipairs(stockPile.wasteTable) do card:checkForMouseOver(grabber) end

end

function love.mousepressed(x, y)
    if x > resetButton.posX and x < resetButton.posX + resetButton.sizeX
    and y > resetButton.posY and y < resetButton.posY + resetButton.sizeY
    then
      love.load()
    end
end


