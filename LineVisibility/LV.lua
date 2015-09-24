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
   self.tolerance = 1

   -- set distance, angle for each point
   local P = self.p
   for _,p in ipairs(self.points) do
      local px,py = p.x - P.x, p.y - P.y

      p.value = Vector.len(px,py)
      p.angle = Vector.angleTo(px,py)

      if p.value > self.maxDist then self.maxDist = p.value end
   end

   local startSweepLine = self:getSweepLine(-1,0)

   -- init all lines with starting points
   for _,l in ipairs(self.lines) do
      -- reset visibility,and set startpoint ref
      l:init()
      -- if line crosses sweepline: revers start point and add to status
      if self:intersection(l,startSweepLine) then
         print("INTERSECTION")
         l:reverseStartPoint()
         self.status:insert(l.startPoint,l)
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

function LV:getSweepLine(x,y)
   local P = self.p
   
   local dx,dy = x - P.x, y - P.y

   dx,dy = Vector.normalize(dx,dy)
   dx,dy = dx*(self.maxDist*2),dy*(self.maxDist *2)

   return Line:new(self.p,Point:new(dx,dy,self.scene),self.scene)
end

function LV:distBetweenPoints(p1,p2)
   return Vector.dist(p1.x,p1.y,p2.x,p2.y)
end
function LV:distToP(point)
   local P = self.p
   return Vector.dist(P.x,P.y,point.x,point.y)
end


function LV:setVisible()
   for _,p in ipairs(self.points) do
      local sl = self:getSweepLine(p.x,p.y) 
      if p.isStartPoint then
         self.status:insert(p,p.line)
         local minN = self.status:getMin()
         local isp = self:intersection(sl,minN:getValue())    
         if p:getValue() <= self:distToP(isp) then
            self.status:getMin():getValue():setVisible()
         end
      else
         self.status:delete(p)
         if self.status:getMin() ~= nil then
            local isp = self:intersection(sl,self.status:getMin():getValue())    
            if p:getValue() <= self:distToP(isp) then
               self.status:getMin():getValue():setVisible()
            end
         end
      end
   end
end


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
      if l2.p1.value < l2.p2.value then
         return l2.p1 
      else 
            return l2.p2
      end
      --return nil 
   end

   local firstPart,lastPart = (x1*y2-y1*x2),(x3*y4-y3*x4)

   local x = (firstPart*(x3-x4)-(x1-x2)*lastPart)/denom
   local y = (firstPart*(y3-y4)-(y1-y2)*lastPart)/denom
   print(x,y, "intersec")
      print("x",x,">=",math.min(l2.p1.x,l2.p2.x),x >= math.min(l2.p1.x,l2.p2.x))
      print("x",x,"<=",math.max(l2.p1.x,l2.p2.x),x <= math.max(l2.p1.x,l2.p2.x))
      print("y",y,">=",math.min(l2.p1.y,l2.p2.y),y >= math.min(l2.p1.y,l2.p2.y))
      print("y",y,"<=",math.max(l2.p1.y,l2.p2.y),y <= math.max(l2.p1.y,l2.p2.y))

   if     x >= math.min(l2.p1.x,l2.p2.x)
      and x <= math.max(l2.p1.x,l2.p2.x)
      and y >= math.min(l2.p1.y,l2.p2.y)
      and y <= math.max(l2.p1.y,l2.p2.y) then

      return Point:new(x,y,self.scene)
   else 
      return nil
   end
end

function LV:draw()

end

return LV
