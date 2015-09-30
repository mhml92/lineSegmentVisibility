
math.random = love.math.random
require 'GLOBALS'
DEBUG = true
Class = require 'middleclass/middleclass'
Scene = require 'Scene'
Entity = require 'Entity'
Vector = require 'vector-light'
ResourceManager = require 'ResourceManager'

local MainScene = require 'MainScene'

local time = {}
time.fdt = 1/60 --fixed delta time
time.accum = 0


local self = {}


function love.load()
   --love.mouse.setVisible(false)
   local w,h = love.graphics.getDimensions()
   love.graphics.setScissor( 0, 0, w, h)
   resmgr = ResourceManager:new()
   self.scene = MainScene:new(self.resmgr)

   love.graphics.setBackgroundColor(OFFWHITE)
   
end

function love.update(dt)
   time.accum = time.accum + dt 
   if time.accum >= time.fdt then
      self.scene:update(time.fdt)
      self.scene:resetInput() -- fixes uncatched mouse and keyboard input
      time.accum = 0
   end
end

function love.draw()
   self.scene:draw()
   love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 10, love.graphics.getHeight()-20) 
end 

function love.keypressed( key, isrepeat )
   if key == "escape" then
      love.event.quit()
   end
   self.scene:keypressed(key,isrepeat)
end

function love.keyreleased( key, isrepeat )
   self.scene:keyreleased(key,isrepeat)
end

function love.mousepressed(x,y,button)
   self.scene:mousepressed(x,y,button)
end

function love.mousereleased(x,y,button)
   self.scene:mousereleased(x,y,button)
end

function beginContact(a,b,coll)
   self.scene:beginContact(a,b,coll)
end

function endContact(a,b,coll)
   self.scene:endContact(a,b,coll)
end

function preSolve(a,b,coll)
   self.scene:preSolve(a,b,coll)
end

function postSolve(a, b, coll, normalimpulse1, tangentimpulse1, normalimpulse2, tangentimpulse2)
   self.scene:postSolve(a, b, coll, normalimpulse1, tangentimpulse1, normalimpulse2, tangentimpulse2)
end
