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
         local d = Line.static:dist(mx,my,v.x,v.y)
         if d < dist then
            dist = d
            closest = v
         end
      else 
         closest = v
         dist = Line.static:dist(mx,my,v.x,v.y)
      end
   end
   self.scene.p:setMarked(false)
   -- check if p is closer
   local d = Line.static:dist(mx,my,self.scene.p.x,self.scene.p.y)
   if dist then
      if d < dist then
         dist = d
         closest = self.scene.p
      end
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
   if dist then
      if dist < POINT_GRAB_DIST then
         closest:setMarked(true)
      end
   end
end

function ActionManager:add(mx,my,closest,dist) 
   if not self.scene.mouseDown["l"] then self.mouseReleased = true end

   if self.scene.mouseDown["l"] and self.mouseReleased and not self.addLineA then
      self.mouseReleased = false 
      if not self.addLineA then
         self.addLineA = Point:new(
         math.floor((mx/GRID_X+(GRID_X/2)/GRID_X))*GRID_X,
         math.floor((my/GRID_Y+(GRID_Y/2)/GRID_Y))*GRID_Y,
         self.scene)
         self.scene:addEntity(self.addLineA)
         table.insert(self.scene.points,self.addLineA)

         self.addLineB =  Point:new(
         math.floor((mx/GRID_X+(GRID_X/2)/GRID_X))*GRID_X,
         math.floor((my/GRID_Y+(GRID_Y/2)/GRID_Y))*GRID_Y,
         self.scene)
         self.scene:addEntity(self.addLineB)
         table.insert(self.scene.points,self.addLineB)
         local l = Line:new(self.addLineA,self.addLineB,self.scene)
         self.scene:addEntity(l)
         table.insert(self.scene.lines, l)
      end
   elseif self.addLineB then
      self.addLineB.x = math.floor((mx/GRID_X+(GRID_X/2)/GRID_X))*GRID_X
      self.addLineB.y = math.floor((my/GRID_Y+(GRID_Y/2)/GRID_Y))*GRID_Y

      if self.scene.mouseDown["l"] and self.mouseReleased then
         self.mouseReleased = false 
         self.addLineA = nil
         self.addLineB = nil
      end
   end

end
function ActionManager:remove(mx,my,closest,dist) 
   if not self.scene.mouseDown["l"] then self:markClosest(closest,dist) end

   if self.scene.mouseDown["l"] and dist and closest ~= self.scene.p then
      
      -- if close enogh to grap
      if dist < POINT_GRAB_DIST then
         self.grabbedObject = closest
      end

      local p1,p2
      for _,p in ipairs(self.scene.points) do
         if p == self.grabbedObject then
            p1 = p
            p2 = p.other
            break
         end
      end

      for i=#self.scene.lines,1,-1 do
         if self.scene.lines[i].p1 == p1 or self.scene.lines[i].p1 == p2 then
            self.scene.lines[i]:kill()
            table.remove(self.scene.lines, i)
         end
      end

      for i=#self.scene.points,1,-1 do
         if self.scene.points[i] == p1 or self.scene.points[i] == p2 then
            self.scene.points[i]:kill()
            table.remove(self.scene.points, i)
         end
      end
      -- drag something
   end
end

function ActionManager:move(mx,my,closest,dist) 
   if not self.scene.mouseDown["l"] then self:markClosest(closest,dist) end
   -- grab for something
   if dist and self.scene.mouseDown["l"] and self.grabbedObject == nil and not self.mouseDown then
      -- if close enogh to grap
      if dist < POINT_GRAB_DIST then
         self.grabbedObject = closest
      else
         self.mouseDown = true
      end


      -- drag something
   end
   if self.scene.mouseDown["l"] and self.grabbedObject ~= nil then
      self.grabbedObject.x = math.floor((mx/GRID_X+(GRID_X/2)/GRID_X))*GRID_X
      self.grabbedObject.y = math.floor((my/GRID_Y+(GRID_Y/2)/GRID_Y))*GRID_Y
   end

   if not self.scene.mouseDown["l"] and self.grabbedObject then
      self.grabbedObject = nil
   end

end

return ActionManager
