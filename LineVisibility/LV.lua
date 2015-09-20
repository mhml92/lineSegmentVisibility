local LV = Class("LV")

local RBTree = require 'RBTree/RBTree'
local Node = require 'RBTree/Node'
local Point = require 'entities/Point'
local Line = require 'entities/Line'

local I = require('inspect')

function LV:initialize(points,lines,p,scene)
   self.scene = scene
   self.p = p
   self.points = points
   self.lines = lines
   self.status = RBTree:new()
   self.sweepLine = Line:new(Point:new(self.p.x,self.p.y,self.scene),Point:new(1000,self.p.y,self.scene),self.scene) 

   self.debugLines = {t1={},t2={},t3={}}


   local p1,p2 = self.sweepLine.p1,self.sweepLine.p2
   local vx,vy = p2.x-p1.x,p2.y,p1.y


   --add distance for each point
   for _,p in ipairs(self.points) do
      p:setValue(Vector.dist(self.p.x,self.p.y,p.x,p.y))
   end

   table.sort(self.points, function(p1,p2)
      local v1,v2 = Vector.angleTo(self.p.x-p1.x,self.p.y-p1.y), Vector.angleTo(self.p.x-p2.x,self.p.y-p2.y)
      --normalie to start from zero
      --v1 = v1 < 0 and 1-v1 or v1 
      --v2 = v2 < 0 and 1-v2 or v2

      if v1 < v2 then
         return true
      elseif v1 == v2 then
         local d1,d2 = p1:getValue(),p2:getValue() 
         if d1 < d2 then 
            return true 
         else 
            return false 
         end
      else
         return false
      end
   end)

   --dirty hack, add numbers to points
   for k,point in ipairs(self.points) do
      point.number = k
   end

   self:prettyPrint()

   self:addStartingPoints()

   self:runAlg()
end

function LV:addStartingPoints()
   for _,p in ipairs(self.points) do
      --check if the staring points are on both sides of the initial line
      if p.x > self.p.x and p.other.x > self.p.x and 
         p.y < self.p.y and p.other.y >= self.p.y then
         
         print(p,"Point added to initial status")
         self:addToStatus(p)
         p:setVisible(1)
      end
   end
end

function LV:addToStatus(p)
   p.node = Node:new(0,p,nil,nil,self.status.null)
   self.status:insert(p.node)
end

function LV:checkCloser(point,test)
   if test == self.status.null then
      print("test is null")
      return false
   end

   if point ~= test:getObject().line.p1 and point ~= test:getObject().line.p2 then
      --create lines
      local l1 = {} 
      l1.x,l1.y = test:getObject().line.p1.x,test:getObject().line.p1.y
      l1.x2,l1.y2 = test:getObject().line.p2.x,test:getObject().line.p2.y
      table.insert(self.debugLines.t1, l1)

      local l2 = {} 
      l2.x,l2.y = self.p.x,self.p.y --our main point
      l2.x2,l2.y2 = point.x,point.y -- our current point
      table.insert(self.debugLines.t2, l2)

      if self:lineIntersection(l1,l2) then
         print("found intersection")
         table.insert(self.debugLines.t3, l1)
         table.insert(self.debugLines.t3, l2)

         return true
      end

      return self:checkCloser(point,test.left) or self:checkCloser(point,test.right)
   else
      print("skipped")
      return self:checkCloser(point,test.left) or self:checkCloser(point,test.right)
   end
   
   return false
end

function LV:runAlg()
   for _,point in ipairs(self.points) do
      print("testing")

      self:addToStatus(point)

      print(point.node.left == self.status.null, point.node.left == self.status.null)

      --iterate all possible node below current point
      local found = self:checkCloser(point,self.status.root)

      --[[while(test ~= self.status.null and point ~= (test:getObject().line.p1 or test:getObject().line.p1)) do
         --create lines
         local l1 = {} 
         l1.x,l1.y = test:getObject().line.p1.x,test:getObject().line.p1.y
         l1.x2,l1.y2 = test:getObject().line.p2.x,test:getObject().line.p2.y
         table.insert(self.debugLines.t1, l1)

         local l2 = {} 
         l2.x,l2.y = self.p.x,self.p.y --our main point
         l2.x2,l2.y2 = point.x,point.y -- our current point
         table.insert(self.debugLines.t2, l2)

         if self:lineIntersection(l1,l2) then
            print("found intersection")
            found = true
            break
         end

         test = test.left
      end]]


      if not found then
         print("point should be visible")
         point:setVisible(1)
      else
         point:setVisible(0)
         print("point should not be visible")
      end

      if point.node and point.other.node then
         self.status:delete(point.node)
         self.status:delete(point.other.node)
      end
   end
end

--http://gamedev.stackexchange.com/questions/26004/how-to-detect-2d-line-on-line-collision
function LV:lineIntersection(line, line2)
   --local tl = {x=self.x-self.velx,y=self.y-self.vely,x2=self.x,y2=self.y+9}

   local a,b,c,d = 
   {X=line2.x,Y=line2.y},
   {X=line2.x2,Y=line2.y2},
   {X=line.x,Y=line.y},
   {X=line.x2,Y=line.y2}

    local denominator = ((b.X - a.X) * (d.Y - c.Y)) - ((b.Y - a.Y) * (d.X - c.X));
    local numerator1 = ((a.Y - c.Y) * (d.X - c.X)) - ((a.X - c.X) * (d.Y - c.Y));
    local numerator2 = ((a.Y - c.Y) * (b.X - a.X)) - ((a.X - c.X) * (b.Y - a.Y));

    -- Detect coincident lines (has a problem, read below)
    if denominator == 0 then return numerator1 == 0 and numerator2 == 0 end

    local r = numerator1 / denominator
    local s = numerator2 / denominator

    return (r >= 0 and r <= 1) and (s >= 0 and s <= 1)
end

function LV:draw()
   self.sweepLine:draw()


   --print(I(self.debugLines))
   --love.graphics.setLi
   love.graphics.setLineWidth(0.25)
   for _,l in pairs(self.debugLines.t1) do
      love.graphics.setColor(GREENSEA)
      --love.graphics.line(l.x,l.y,l.x2,l.y2)
   end
   for _,l in pairs(self.debugLines.t2) do
      love.graphics.setColor(MIDNIGHTBLUE)
      --love.graphics.line(l.x,l.y,l.x2,l.y2)
   end 
   for _,l in pairs(self.debugLines.t3) do
      love.graphics.setColor(DARKRED)
      love.graphics.line(l.x,l.y,l.x2,l.y2)
   end
end

function LV:prettyPrint()
   for k,v in ipairs(self.points) do
      print("P["..k.."]",v.x,v.y,Vector.angleTo(self.p.x,self.p.y,v.x,v.y),v:getValue())
   end
end

return LV
