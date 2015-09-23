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
   self.maxDist = 0

   -- set distance, angle for each point
   for _,p in ipairs(self.points) do
      p.value = Vector.dist(self.p.x,self.p.y,p.x,p.y)
      p.angle = Vector.angleTo(p.x-self.p.x,p.y-self.p.y)
      if p.value > self.maxDist then self.maxDist = p.value end
   end
   self.startSweepLine = self:getSweepLine(self.p,-1,0)

   -- init all lines with starting points
   for _,l in ipairs(self.lines) do
--[[      if l.p1.angle < l.p2.angle then
         l.p1.isStartPoint = true
      elseif l.p1.angle > l.p2.angle then
         l.p2.isStartPoint = true
      else
         if l.p1:getValue() < l.p2:getValue() then
            l.p1.isStartPoint = true
         else
            l.p2.isStartPoint = true
         end
      end
      ]]
      -- reset visibility,and set startpoint ref
      l:init()
      -- if line crosses sweepline: revers start point and add to status
      if self:intersection(l,self.startSweepLine) then
         print("INTERSECTION")
         l:reverseStartPoint()
         self.status:insert(l.startPoint,l)
      else
         print("non")
      end
   end

   table.sort(self.points, function(p1,p2)
      if p1.angle < p2.angle then
         return true
      elseif p1.angle > p2.angle then
         return false
      else 
         if p1.isStartPoint and p2.isStartPoint then
            return p1:getValue() < p2:getValue()
         elseif not p1.isStartPoint and not p2.isStartPoint then
            return p1:getValue() > p2:getValue()
         elseif p1.isStartPoint and not p2.isStartPoint then
            return true
         elseif not p1.isStartPoint and p2.isStartPoint then
            return false
         end
      end
   end)

   --dirty hack, add numbers to points
   for k,point in ipairs(self.points) do
      point.number = k
      print(point.angle,k)
   end

   self:setVisible()
end

function LV:getSweepLine(p1,x,y)
   local dx,dy = self.p.x + x,self.p.y + y
   dx,dy = Vector.normalize(dx-self.p.x,dy-self.p.y)
   dx,dy = dx*(self.maxDist+1),dy*(self.maxDist +1)
   return Line:new(p1,Point:new(dx,dy,self.scene),self.scene)
end


function LV:setVisible()
   for _,p in ipairs(self.points) do
      if p.isStartPoint then
         self.status:insert(p,p.line)
         self.status:getMin():getValue():setVisible()
      else
         self.status:delete(p)
         if self.status:getMin() ~= nil then
            self.status:getMin():getValue():setVisible()
         end
      end
   end
end


-- https://en.wikipedia.org/wiki/Line%E2%80%93line_intersection#Intersection_of_two_lines
function LV:intersection(l1,l2)
   local x1,y1, 
   x2,y2, 
   x3,y3, 
   x4,y4 = 
   l1.p1.x,l1.p1.y,
   l1.p2.x,l1.p2.y,
   l2.p1.x,l2.p1.y,
   l2.p2.x,l2.p2.y

   local denom = (x1-x2)*(y3-y4)-(y1-y2)*(x3-x4)
   if denom == 0 then 
      return nil 
   end

   local firstPart,lastPart = (x1*y2-y1*x2),(x3*y4-y3*x4)

   local x = (firstPart*(x3-x4)-(x1-x2)*lastPart)/denom
   local y = (firstPart*(y3-y4)-(y1-y2)*lastPart)/denom

   local l1minx,l1maxx = math.min(l1.p1.x,l1.p2.x),math.max(l1.p1.x,l1.p2.x) 
   print(x,l1minx,l1maxx)
   print(
      x >= math.min(l1.p1.x,l1.p2.x), 
      x <= math.max(l1.p1.x,l1.p2.x), 
      x >= math.min(l2.p1.x,l2.p2.x),
      x <= math.max(l2.p1.x,l2.p2.x),
      y >= math.min(l1.p1.y,l1.p2.y),
      y <= math.max(l1.p1.y,l1.p2.y),
      y >= math.min(l2.p1.y,l2.p2.y),
      y <= math.max(l2.p1.y,l2.p2.y)
   )
   if     x >= math.min(l1.p1.x,l1.p2.x) 
      and x <= math.max(l1.p1.x,l1.p2.x) 
      and x >= math.min(l2.p1.x,l2.p2.x) 
      and x <= math.max(l2.p1.x,l2.p2.x) 
      and y >= math.min(l1.p1.y,l1.p2.y)
      and y <= math.max(l1.p1.y,l1.p2.y)
      and y >= math.min(l2.p1.y,l2.p2.y)
      and y <= math.max(l2.p1.y,l2.p2.y) then

      return Point:new(x,y,self.scene)
   else 
      print("lel")
      return nil
   end
end

return LV
