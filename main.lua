function love.load()
  background = love.graphics.newImage('assets/background.png')
  heart = love.graphics.newImage('assets/heart.png')
  love.window.setMode(1280, 720, {fullscreen=false, fullscreentype="exclusive"})
  love.window.setTitle("kotek")
  love.graphics.setDefaultFilter("nearest", "nearest")
  kot = love.graphics.newImage("assets/kot.png")
  sadkot = love.graphics.newImage("assets/sadkot.png")
  kottree = love.graphics.newImage("assets/kottree.png")
  rat = love.graphics.newImage("assets/rat.png")
  flyingrat = love.graphics.newImage("assets/flyingrat.png")
  currkot = kot
  rats = {}
  totalrats = 5
  kothealth = 10
  kot_hitboxes = {
    {x = 619, y = 388-77, w = 60, h = 156},
    {x = 605, y = 465-77, w = 17, h = 22},
    {x = 585, y = 488-77, w = 38, h = 52}
  }
  paths = {
    {x1 = 0, y1 = 500, distance = 380},
    {x1 = 0, y1 = 250, distance = 420},
    {x1 = 1280, y1 = 250, distance = 420},
    {x1 = 1280, y1 = 500, distance = 380}
  }
  keys = {"a", "s", "k", "l"}
  points = 0
  misses = 0
end

function love.update(dt)
  for i=#rats, 1, -1 do
    --rat movement
    angle = math.atan2(400 - 77 - rats[i].y, 640 - rats[i].x)
    rats[i].x = rats[i].x + math.cos(angle) * rats[i].speed
    rats[i].y = rats[i].y + math.sin(angle) * rats[i].speed

    --collision based rat destroying
    for j = 1, #kot_hitboxes do
      if checkCollision(kot_hitboxes[j].x, kot_hitboxes[j].y, kot_hitboxes[j].w, kot_hitboxes[j].h, rats[i].x-rat:getWidth()/2, rats[i].flying == 0 and rats[i].y-rat:getHeight()/2 or rats[i].y + 70, rat:getWidth(), rat:getHeight()) then
        kothealth = kothealth - 1
        destroy_enemy(rats[i].id)
        currkot = sadkot
        sadcountdown = 1000
        break
      end
    end

    if currkot == sadkot then
      sadcountdown = sadcountdown -  math.floor(dt*1000 - 10)
      if sadcountdown < 100 then
        currkot = kot
      end
    end

  end

  if #rats < totalrats then
    add_enemy()
  end

end


function love.draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(background)
  love.graphics.setBackgroundColor(55/255, 55/255, 55/255)
  love.graphics.setColor(1, 1, 1)
  --love.graphics.line(0, 560, 1280, 560)
  love.graphics.print("POINTS: " .. points, 1100, 700)
  love.graphics.print("MISSES: " .. misses, 1100, 680)

  love.graphics.draw(currkot, love.graphics.getWidth()/2, love.graphics.getHeight()/2+23, 0, 1, 1, kot:getWidth()/2, kot:getHeight()/2)
  local angle = {}
  local x2 = 640
  local y2 = 460 - 77
  for i=1, #paths do
    --love.graphics.setColor(1, 1, 1)
    --love.graphics.line(paths[i].x1, paths[i].y1, x2, y2) --draw paths

    angle[i] = math.atan2(y2 - paths[i].y1, x2 - paths[i].x1)
    local w = paths[i].x1 + math.cos(angle[i]) * paths[i].distance
    local h = paths[i].y1 + math.sin(angle[i]) * paths[i].distance

    love.graphics.print(keys[i], w + 10, h)
    love.graphics.rectangle('line', w , h - 10, 25, 25) --draw hitpoints
  end

  love.graphics.setColor(1, 1, 1)
  for i=1, kothealth do
    love.graphics.draw(heart, -30+100*i - 50, 625)
  end
  love.graphics.setColor(1, 1, 1)


  for i = 1,#rats do
    --draw rats
    love.graphics.draw(rats[i].sprite, rats[i].x, rats[i].y, 0, rats[i].dir, 1, rat:getWidth()/2, rat:getHeight()/2)

    --draw rats hitboxes
    --love.graphics.rectangle('line', rats[i].x-rat:getWidth()/2, rats[i].flying == 0 and rats[i].y-rat:getHeight()/2 or rats[i].y + flyingrat:getHeight()/2 + 13, rat:getWidth(), rat:getHeight())
  end

  --cat hitboxes
  --[[
  for i = 1, #kot_hitboxes do
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle('line', kot_hitboxes[i].x, kot_hitboxes[i].y, kot_hitboxes[i].w, kot_hitboxes[i].h)
  end
  --]]


end

function destroy_enemy(id)
  for i=#rats, 1, -1 do
    if(rats[i].id == id) then
      table.remove(rats, i)
    end
  end
end

function add_enemy()
  local id = generate_id()
  local flying = 1
  local sprite = flying == 1  and flyingrat or rat
  local pos = math.floor(love.math.random(1, 4))
  local x = paths[pos].x1
  local y = paths[pos].y1 - flyingrat:getHeight()
  local dir = pos < 3 and 1 or -1
  local speed = love.math.random(1.4,2)
  table.insert(rats, {id = id, flying = flying, sprite=sprite, x = x, y = y, dir = dir, speed = speed})
end

function generate_id()
  local template ='xxxxxxx'
  return string.gsub(template, '[xy]', function (c)
  local v = (c == 'x') and love.math.random(0, 0xf) or love.math.random(8, 0xb)
  return string.format('%x', v)
  end)
end

--snippet from https://love2d.org/wiki/BoundingBox.lua
function checkCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  -- Collision detection function;
  -- Returns true if two boxes overlap, false if they don't;
  -- x1,y1 are the top-left coords of the first box, while w1,h1 are its width and height;
  -- x2,y2,w2 & h2 are the same, but for the second box.
  return x1 < x2+w2 and
  x2 < x1+w1 and
  y1 < y2+h2 and
  y2 < y1+h1
end


function love.keypressed(key)
  if key == "space" then --debug: print all rats in terminal
    for index, data in ipairs(rats) do
      print(index)
      for key, value in pairs(data) do
        print('\t', key, value)
      end
    end
  elseif key=="b" then
    for i=#rats, 1, -1 do
      destroy_enemy(rats[i].id)
    end
  elseif key =="t" then
    totalrats = totalrats - 1
  elseif key =="y" then
    totalrats = totalrats + 1
  elseif key == "escape" then
    love.event.quit()
  end
  local angle = {}
  local x2 = 640
  local y2 = 460 - 77
  for i=1, #keys do
    if key == keys[i] then
      for j=#rats, 1, -1 do
        angle[i] = math.atan2(y2 - paths[i].y1, x2 - paths[i].x1)
        local w = paths[i].x1 + math.cos(angle[i]) * paths[i].distance
        local h = paths[i].y1 + math.sin(angle[i]) * paths[i].distance
        love.graphics.rectangle('line', w , h - 10, 25, 25) --hitpoints
        collided = checkCollision(w, h - 10, 25, 25, rats[j].x-rat:getWidth()/2, rats[j].flying == 0 and rats[j].y-rat:getHeight()/2 or rats[j].y + 70, rat:getWidth(), rat:getHeight())
        if collided then
          points = points + rats[j].speed * 100
          destroy_enemy(rats[j].id)
          break
        end
      end
      if not collided then
        misses = misses + 1
      end
    end
  end
end