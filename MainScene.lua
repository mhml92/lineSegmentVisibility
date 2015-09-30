local MainScene = Class("MainScene", Scene)
local Menu = require 'entities/Menu'
local CameraManager = require 'CameraManager'
local Point = require 'entities/Point'
local Line = require 'entities/Line'
local Grid = require 'entities/Grid'
local ActionManager = require 'ActionManager'
local LV = require 'LineVisibility/LV'
local Fire = require 'entities.sauronfire'

---------------------------------------------------------------------
--										INITIALIZE
---------------------------------------------------------------------
function MainScene:initialize()
   Scene:initialize(resmgr)
   self.menu = Menu:new(0,0,self)
   self.cammgr = CameraManager:new(self)
   self.actmgr = ActionManager:new(self)
   self:defineLayers()
   self.p = nil
   self.points = {}
   self.lines = {}
   self.drawDebugLines = false
   self.runeachframe = false
   self.sauronMode = false
   self.fire = Fire:new(self)

   self:addEntity(Grid:new(self))
   -----------------------------------------------------------------
   -- READ INPUT FILE
   -----------------------------------------------------------------
   inputArg = arg[2] or nil
   outputArg = arg[3] or nil
   if inputArg then
      io.input(inputArg)
      while true do
         local line = io.read()
         if line == nil then break end
      
         -- trim all whitespace
         line = line:gsub("%s+", "")
         if line:sub(1,1) ~= "#" and line ~= "" then
            local pList = {}
            -- split line on ';'
            for s in line:gmatch('([^;%s]+)') do
               pval =  {}
               for val in s:gmatch('([^,%s]+)') do
                  table.insert(pval,val)
               end
               table.insert(pList,Point:new(GRID_X * pval[1],GRID_Y * pval[2],self))  
            end
            if #pList == 1 then
               self.p = pList[1]
               self:addEntity(self.p)
               self.p:setViewPoint()
               self.cammgr:setCenter(self.p.x,self.p.y)
            else 
               local line = Line:new(pList[1],pList[2],self)
               table.insert(self.lines, line)

               self:addEntity(line)
               self:addEntity(pList[1])
               self:addEntity(pList[2])
               table.insert(self.points,pList[1])
               table.insert(self.points,pList[2])
            end
         end
      end

      --run LV
      self.LV = LV:new(self.points,self.lines,self.p,self,self.co)
      self.LV:addStartingPoints()
      self.LV:runAlg()

      if outputArg then
         --output all visible lines and exit program
         io.output(outputArg)
         io.write("#point\n"..self.p.x/GRID_X..","..self.p.y/GRID_Y.."\n\n")

         for _,line in ipairs(self.lines) do
            if line.p1:isVisible() or line.p2:isVisible() then
               io.write(line.p1.x/GRID_X..","..line.p1.y/GRID_Y..";"..line.p2.x/GRID_X..","..line.p2.y/GRID_Y.."\n")
            end
         end
         love.event.quit()
      end
   else
      msg = [[ 
      +-----------------------------------------+
      | No input given - Build some yourself :) | 
      +-----------------------------------------+
      ]]
      print(msg)
      self.p = Point:new(0,0,self)
      table.insert(self.points,p)
      self:addEntity(self.p)
      self.p:setViewPoint()
      self.cammgr:setCenter(self.p.x,self.p.y)
   end
end

function Scene:defineLayers()

   self:addLayer("Grid")
   self:addLayer("Line")
   self:addLayer("Point")
end
---------------------------------------------------------------------
--										UPDATE
---------------------------------------------------------------------
function Scene:update(dt)
   local mx,my = love.mouse.getPosition()
   self.fire:update(dt)
   self.actmgr:update(dt)
   self.cammgr:update(mx,my,dt)
   self.menu:update(dt)
   for i, v in ipairs(self.entities) do
      if v:isActive() then
         v:update(dt)
      end
   end
   for i=#self.entities, 1, -1 do
      if self.entities[i]:isAlive() == false then
         if self.entities[i].body then
            self.entities[i].body:destroy()
         end
         table.remove(self.entities, i);
      end
   end
   self.mouseDown["wd"] = nil
   self.mouseDown["wu"] = nil
   if self.runeachframe then
      self:run()
   end
end

---------------------------------------------------------------------
--										DRAW
---------------------------------------------------------------------
function Scene:draw()
   -- sort entities by their layer
   table.sort(self.entities,
   function(a,b) 
      if a.layer < b.layer then 
         return true 
      elseif a.layer == b.layer then 
         if a.id < b.id then 
            return true 
         else 
            return false 
         end 
      else 
         return false 
      end 
   end)

   self.cammgr:attach()	
   for i, v in ipairs(self.entities) do
      if v:isActive() then
         v:draw()
      end
   end
   if self.drawDebugLines then
      if self.LV then
         self.LV:draw()
      end
   end
   if self.sauronMode then
      love.graphics.setColor(255,255,255)
      love.graphics.draw(resmgr:getImg("sauron.png"),self.p.x,self.p.y,0,0.25,0.25,96/2-3,94/2-3)
      for _,l in pairs(self.lines) do
         if l.p1:isVisible() or l.p2:isVisible() then
            self.fire:draw(l)
         end
      end
   end
   self.cammgr:detach()
   self.menu:draw()
end

---------------------------------------------------------------------
--                            FUNCTIONS
---------------------------------------------------------------------
function Scene:keypressed(key)
end

function Scene:run()
   self.LV = LV:new(self.points,self.lines,self.p,self,nil)
   self.LV:addStartingPoints()
   self.LV:runAlg()
end

--create step coroutine
function Scene:startStep()
   self.co = coroutine.create(function()
      self.LV = LV:new(self.points,self.lines,self.p,self,self.co)
      if self.coroutine then
         coroutine.yield()
      end
      self.LV:addStartingPoints()
      self.LV:runAlg()
   end)
   coroutine.resume(self.co)
end

--do a step
function Scene:doStep()
   if self.co then
      coroutine.resume(self.co)
   end
end

return MainScene
