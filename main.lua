-- Jim Lee
-- CMPM 121 - Solitaire
-- 4-7-2025
io.stdout:setvbuf("no")

require("card")
require("grabber")
require("stockpile")
require("cardpile")

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



function love.load()
  love.window.setTitle("Solitaire'nt")
  love.window.setMode(960, 640)
  love.graphics.setBackgroundColor(0, 0.7, 0.2, 1)
  math.randomseed(os.time())

  grabber = GrabberClass:new()
  cardPileTable = {}
  stockPile = StockPile:new(50, 50)

  -- table cards
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

  -- finished piles
  table.insert(cardPileTable, CardPile:new(800, 50, true))
  table.insert(cardPileTable, CardPile:new(800, 150, true))
  table.insert(cardPileTable, CardPile:new(800, 250, true))
  table.insert(cardPileTable, CardPile:new(800, 350, true))
end

function love.update()
  grabber:update()

  checkForMouseMoving()

  for _, cardPile in ipairs(cardPileTable) do
    cardPile:update()
  end

end

function love.draw()
  stockPile:draw()

  for _, cardPile in ipairs(cardPileTable) do
    cardPile:draw()
  end

  grabber:draw()
end

function checkForMouseMoving()
  if grabber.currentMousePos == nil then
    return
  end

  for i, cardPile in ipairs(cardPileTable) do
    for j, card in ipairs(cardPile.cardTable) do
      card:checkForMouseOver(grabber)
    end
  end  
end

-- https://love2d.org/forums/viewtopic.php?t=11623
local lastclick = 0
local clickInterval = 0.2 -- seconds between to count as double click

-- why is the love.mousepressed(x, y, button) version gone but this one isn't
function love.mousepressed(x, y)
    local time = love.timer.getTime()
    if time <= lastclick + clickInterval then
        flipCard()
    else
        lastclick = time
    end
end

function flipCard()
  for _, cardPile in ipairs(cardPileTable) do
    for _, card in ipairs(cardPile) do
      if card.state == 1 then
        card.faceUp = not card.faceUp
        return
      end
    end
  end
end
