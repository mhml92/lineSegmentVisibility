local MainScene = Class("MainScene", Scene)
local Menu = require 'entities/Menu'
local CameraManager = require 'CameraManager'
local Point = require 'entities/Point'
local Line = require 'entities/Line'
local Grid = require 'entities/Grid'
local ActionManager = require 'ActionManager'
local LV = require 'LineVisibility/LV'

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

   self:addEntity(Grid:new(self)) 
   -----------------------------------------------------------------
   -- READ INPUT FILE
   -----------------------------------------------------------------
   inputArg = arg[2] or ""
   print(inputArg)
   if io.input(inputArg) then
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
               self:addEntity(Line:new(pList[1],pList[2],self))
               self:addEntity(pList[1])
               self:addEntity(pList[2])
               table.insert(self.points,pList[1])
               table.insert(self.points,pList[2])
            end
         end
      end
      self.LV = LV:new(self.points,self.lines,self.p,self)
   else
      msg = [[ 
      +-----------------------------------------+
      | No input given - Build some yourself :) | 
      +-----------------------------------------+
      ]]
      print(msg)
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
   self.LV:draw()
   self.cammgr:detach()
   self.menu:draw()
end

return MainScene
