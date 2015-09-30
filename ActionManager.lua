local ActionManager = Class('ActionManager')
local Line = require 'entities/Line'
local Point = require 'entities/Point'
local Line = require 'entities/Line'

function ActionManager:initialize(scene)
   self.scene = scene
   self.MODE = "MOVE"
   self.grabbedObject = nil
   self.mouseDown = false
   self.mouseReleased = true
   self.addLineA = nil
   self.addLineB = nil
   self.snap = true
end

function ActionManager:update(dt)
   local mx,my = self.scene.cammgr.cam:worldCoords(love.mouse.getPosition())
   if not self.scene.mouseDown["l"] then self.mouseDown = false end

   -- distance and closest obj
   local closest = nil 
   local dist = nil
   -- find closest point
   for k,v in ipairs(self.scene.points) do
      v:setMarked(false)
      if closest ~= nil then
         local d = Vector.dist(mx,my,v.x,v.y)
         if d < dist then
            dist = d
            closest = v
         end
      else 
         closest = v
         dist = Vector.dist(mx,my,v.x,v.y)
      end
   end
   self.scene.p:setMarked(false)
   -- check if p is closer
   local d = Vector.dist(mx,my,self.scene.p.x,self.scene.p.y)
   if not dist or d < dist then
      dist = d
      closest = self.scene.p
   end


   if love.mouse:getX() > self.scene.menu.width then
      if self.MODE == "MOVE" then
         self:move(mx,my,closest,dist)
      elseif self.MODE == "ADD" then
         self:add(mx,my,closest,dist)
      elseif self.MODE == "REMOVE" then
         self:remove(mx,my,closest,dist)
      end
   end
end

function ActionManager:changeMode(m)
   self.MODE = m
end

function ActionManager:markClosest(closest,dist)
   if dist < POINT_GRAB_DIST then
      closest:setMarked(true)
   end
end

function ActionManager:toggleSnap()
   self.snap = not self.snap
end

function ActionManager:dumpToFile()
   local P = self.scene.p
   local lines = self.scene.lines
   file = io.open("dm819-output.txt","w")
   io.output(file)
   -- write P
   local Pstr = P.x/GRID_X ..","..P.y/GRID_Y.."\n"
   print(Pstr)
   io.write("# view point P\n")
   io.write(Pstr)

   io.write("# Lines\n")
   for _,l in ipairs(lines) do
      local Lstr = l.p1.x/GRID_X .. "," .. l.p1.y/GRID_Y ..";"..l.p2.x/GRID_X .. ","..l.p2.y/GRID_Y .."\n"
      print(Lstr)
      io.write(Lstr)
   end
   io.close(file)
end


function ActionManager:add(mx,my,closest,dist) 
   if not self.scene.mouseDown["l"] then self.mouseReleased = true end

   if self.scene.mouseDown["l"] and self.mouseReleased and not self.addLineA then
      self.mouseReleased = false 
      if not self.addLineA then
         mx,my = self:toGrid(mx,my)
         self.addLineA = Point:new(
         mx,my,
         self.scene)
         self.scene:addEntity(self.addLineA)
         table.insert(self.scene.points,self.addLineA)

         self.addLineB =  Point:new(
         mx,my,
         self.scene)
         self.scene:addEntity(self.addLineB)
         table.insert(self.scene.points,self.addLineB)
         local l = Line:new(self.addLineA,self.addLineB,self.scene)
         self.scene:addEntity(l)
         table.insert(self.scene.lines,l)
      end
   elseif self.addLineB then
      self.addLineB.x,self.addLineB.y = self:toGrid(mx,my)     
      --self.addLineB.x = math.floor((mx/GRID_X+(GRID_X/2)/GRID_X))*GRID_X
      --self.addLineB.y = math.floor((my/GRID_Y+(GRID_Y/2)/GRID_Y))*GRID_Y

      if self.scene.mouseDown["l"] and self.mouseReleased then
         self.mouseReleased = false 
         self.addLineA = nil
         self.addLineB = nil
      end
   end

end
function ActionManager:remove(mx,my,closest,dist)

   if not self.scene.mouseDown["l"] then self:markClosest(closest,dist) end
   -- grab for something
   if self.scene.mouseDown["l"] and self.grabbedObject == nil and not self.mouseDown then
      -- if close enogh to grap
      if dist < POINT_GRAB_DIST then
         closest.line:kill()
      else
         self.mouseDown = true
      end
   end
end

function ActionManager:move(mx,my,closest,dist) 
   if not self.scene.mouseDown["l"] then self:markClosest(closest,dist) end
   -- grab for something
   if self.scene.mouseDown["l"] and self.grabbedObject == nil and not self.mouseDown then
      -- if close enogh to grap
      if dist < POINT_GRAB_DIST then
         self.grabbedObject = closest
      else
         self.mouseDown = true
      end

      -- drag something
   end
   if self.scene.mouseDown["l"] and self.grabbedObject ~= nil then
      self.grabbedObject.x,self.grabbedObject.y = self:toGrid(mx,my)     
--self.grabbedObject.x = math.floor((mx/GRID_X+(GRID_X/2)/GRID_X))*GRID_X
      --self.grabbedObject.y = math.floor((my/GRID_Y+(GRID_Y/2)/GRID_Y))*GRID_Y
   end

   if not self.scene.mouseDown["l"] and self.grabbedObject then
      self.grabbedObject = nil
   end

end
function ActionManager:toGrid(x,y)
   if self.snap then
      return math.floor((x/GRID_X+(GRID_X/2)/GRID_X))*GRID_X, math.floor((y/GRID_Y+(GRID_Y/2)/GRID_Y))*GRID_Y
   else
      return x,y
   end
end


return ActionManager
