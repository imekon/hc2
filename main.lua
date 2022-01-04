function love.load()
    HC = require "hc"
    
    arenaWidth = 800
    arenaHeight = 600
    
    shipRadius = 30
    
    ship = {}
    ship.angle = 0
    ship.speed = {}
    ship.speed.x = 0
    ship.speed.y = 0
    ship.hc = HC.circle(350, 250, shipRadius)
    
    asteroids = {}
    for i=1,4 do
      createAsteroid(love.math.random(arenaWidth),
        love.math.random(arenaHeight),
        love.math.random() * 2 * math.pi,
        1)
    end
    
    bullets = {}
    bulletSpeed = 500
    bulletRadius = 5
end

function createAsteroid(ax, ay, aAngle, aStage)
  asteroid =
  {
    x = ax,
    y = ay,
    angle = aAngle,
    stage = aStage
  }
  
  asteroid.hc = HC.circle(asteroid.x, asteroid.y, 50 / aStage)
  
  table.insert(asteroids, asteroid)
end


function love.keypressed(key)
  if key == 's' then
    local x, y = ship.hc:center()
    bullet = {}
    bullet.hc = HC.circle(x + math.cos(ship.angle) * shipRadius, y + math.sin(ship.angle) * shipRadius, bulletRadius)
    bullet.delay = 4
    bullet.angle = ship.angle
    table.insert(bullets, bullet)
  end
end

function love.update(dt)
  local turnSpeed = 5
  if love.keyboard.isDown('left') then
    ship.angle = ship.angle - turnSpeed * dt
  elseif love.keyboard.isDown('right') then
    ship.angle = ship.angle + turnSpeed * dt
  elseif love.keyboard.isDown('space') then
    local shipSpeed = 100
    ship.speed.x = ship.speed.x + math.cos(ship.angle) * shipSpeed * dt
    ship.speed.y = ship.speed.y + math.sin(ship.angle) * shipSpeed * dt
  end
  
  local x, y = ship.hc:center()
  x = (x + ship.speed.x * dt) % arenaWidth
  y = (y + ship.speed.y * dt) % arenaHeight
  ship.hc:moveTo(x, y)
  
  for bulletIndex = #bullets,1,-1 do
    local bullet = bullets[bulletIndex]
    bullet.delay = bullet.delay - dt
    
    if bullet.delay < 0 then
      table.remove(bullets, bulletIndex)
    else
      local x, y = bullet.hc:center()
      x = (x + math.cos(bullet.angle) * bulletSpeed * dt) % arenaWidth
      y = (y + math.sin(bullet.angle) * bulletSpeed * dt) % arenaHeight
      bullet.hc:moveTo(x, y)
    end
    
    for asteroidIndex = #asteroids,1, -1 do
      asteroid = asteroids[asteroidIndex]
      if asteroid.hc:collidesWith(bullet.hc) then
        table.remove(asteroids, asteroidIndex)
        table.remove(bullets, bulletIndex)
        
        if asteroid.stage < 4 then
          angle = love.math.random() * 2 * math.pi
          
          asteroid1 = createAsteroid(asteroid.x, asteroid.y, angle, asteroid.stage + 1)
          
          asteroid2 = createAsteroid(asteroid.x, asteroid.y, (angle - math.pi) % (2 * math.pi), asteroid.stage + 1)
        end
        break
      end
    end
  end
  
  -- move asteroids and check collision with ship
  local asteroidSpeed = 20
  for i = #asteroids,1,-1 do
    local asteroid = asteroids[i]
    local x,y = asteroid.hc:center()
    x = (x + math.cos(asteroid.angle) * asteroidSpeed * dt) % arenaWidth
    y = (y + math.sin(asteroid.angle) * asteroidSpeed * dt) % arenaHeight
    asteroid.hc:moveTo(x, y)
    if asteroid.hc:collidesWith(ship.hc) then
      love.load()
    end
  end
end

function love.draw()
  local x,y = ship.hc:center()
  love.graphics.setColor(0,0,1)
  love.graphics.circle('fill', x, y, shipRadius)
  local shipCircleDist = 20
  love.graphics.setColor(0,1,1)
  love.graphics.circle('fill', 
    x + math.cos(ship.angle) * shipCircleDist,
    y + math.sin(ship.angle) * shipCircleDist,
    5)
  love.graphics.setColor(1,1,1)
  ship.hc:draw('line')
  
  love.graphics.setColor(1,1,1)
  for i, asteroid in ipairs(asteroids) do
      asteroid.hc:draw('line')
  end
  
  love.graphics.setColor(1,1,1)
  for i, bullet in ipairs(bullets) do
    bullet.hc:draw('line')
  end
end
