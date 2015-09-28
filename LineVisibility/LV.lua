local LV = Class("LV")

local RBTree = require 'RBTree/RBTree'
local Node = require 'RBTree/Node'
local Point = require 'entities/Point'
local Line = require 'entities/Line'

local I = require('inspect')

function LV:initialize(points,lines,p,scene,co)
   self.scene = scene
   self.p = p
   self.points = points
   self.lines = lines
   self.status = RBTree:new()
   self.coroutine = co

   self.debugLines = {t1={},t2={},t3={},t4={}}
   if self.coroutine then
      coroutine.yield()
   end

   --add distance for each point
   for _,p in ipairs(self.points) do
      --also reset nodes
      p.node = nil

      p:setValue(Vector.dist(self.p.x,self.p.y,p.x,p.y))
   end

   table.sort(self.points, function(p1,p2)
      local v1,v2 = Vector.angleTo(self.p.x-p1.x,self.p.y-p1.y), Vector.angleTo(self.p.x-p2.x,self.p.y-p2.y)

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
      point:setVisible(0)
      point.line:calcDistToP(p)
   end
end

function LV:addStartingPoints()
   for _,p in ipairs(self.points) do
      --check if the staring points are on both sides of the initial line
      if (p.x > self.p.x or p.other.x > self.p.x) and 
         p.y < self.p.y and p.other.y > self.p.y then
         
         --check if points intersect the horizontal line of P
         local a = (p.other.x-p.x)/(p.other.y-p.y)
         local b = p.y-a*p.x

         --now check if line intersects our P point i.e. y+P.y = 0
         local yintersect = (-b+self.p.y)/a-self.p.x

         if yintersect > 0 then
            local l = p.line
            l.node = self.status:insert(l,l)
            --swap points
            l:swapPoints()
            print(p.number,"Point added to initial status")
         end
      end
   end
end


function LV:checkCloser(point,test)
   --if we have reached a null leaf return false
   if test == self.status.null then
      return false
   end

   print("looking in point", point.number)

   --current test line
   local tl = test:getKeyObject()
   if point.line ~= tl then
      print("checking against ",tl.p1.number)
      print("checking against ",tl.p2.number)
      --create lines
      local l1 = {}
      l1.x,l1.y = tl.p1.x,tl.p1.y
      l1.x2,l1.y2 = tl.p2.x,tl.p2.y
      table.insert(self.debugLines.t1, l1)

      local l2 = {}
      l2.x,l2.y = self.p.x,self.p.y --our main point
      l2.x2,l2.y2 = point.x,point.y -- our current point
      table.insert(self.debugLines.t2, l2)

      --print(I(l1),I(l2))
      if self:lineIntersection(l1,l2) then
         table.insert(self.debugLines.t3, l1)
         table.insert(self.debugLines.t3, l2)
         print("FOUND INTERSECTION!")
         return true
      end

      return self:checkCloser(point,test.left) or self:checkCloser(point,test.right)
   else
      local l = {}
      l.x,l.y = self.p.x,self.p.y --our main point
      l.x2,l.y2 = point.x,point.y -- our current point
      table.insert(self.debugLines.t4, l)
      print("skipped")
      return self:checkCloser(point,test.left) or self:checkCloser(point,test.right)
   end
end

function LV:checkPointAndSetVisible(point, startNode)
   local found = self:checkCloser(point,startNode)

   if not found then
      point:setVisible(1)
   else
      point:setVisible(0)
   end
end

function LV:recursiveCheckPointsCloser(startNode)
   if startNode == self.status.null then
      return
   end

   self:checkPointAndSetVisible(startNode:getKeyObject():getFirst(), startNode)

   self:recursiveCheckPointsCloser(startNode.left)
   self:recursiveCheckPointsCloser(startNode.right)
end

function LV:runAlg()
   for _,point in ipairs(self.points) do
      local l = point.line
      --if point is the first in the order
      if point:isFirst() then
         l.node = self.status:insert(l,l)
      end

      print(point.line.node)
      print(point.line.node:getKey())
      print("left",point.line.node.left == self.status.null, "right", point.line.node.right == self.status.null)
      --iterate all possible node below current point
      
      local min = self.status:getMin()
      print("MINIMUM IS ", min:getKeyObject().p1.number)
      self:checkPointAndSetVisible(point, min)
      --[[local found = self:checkCloser(point,self.status.root)

      if not found then
         point:setVisible(1)
      else
         point:setVisible(0)
      end]]

      --if point is the second in order
      if not point:isFirst() then
         self.status:deleteNode(l.node)
         

         --self:recursiveCheckPointsCloser(self.status.root)

         
         local closest = self.status:getMin():getKeyObject()
         
         if closest and closest.p1 then
            print("setting " .. closest:getFirst().number .. " as visible")
            closest:getFirst():setVisible(1)
         end
         --self.status:deleteNode(point.other.node)
         l.node = nil
      end

      --allows step
      if self.coroutine then
         coroutine.yield()
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
   --self.sweepLine:draw()


   --print(I(self.debugLines))
   --love.graphics.setLi
   love.graphics.setLineWidth(0.25)
   for _,l in pairs(self.debugLines.t1) do
      love.graphics.setColor(GREENSEA)
      love.graphics.line(l.x,l.y,l.x2,l.y2)
   end
   for _,l in pairs(self.debugLines.t2) do
      love.graphics.setColor(MIDNIGHTBLUE)
      love.graphics.line(l.x,l.y,l.x2,l.y2)
   end 
   for _,l in pairs(self.debugLines.t4) do
      love.graphics.setColor(YELLOW)
      love.graphics.line(l.x,l.y,l.x2,l.y2)
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

   for k,v in ipairs(self.lines) do
      io.write("p1[num]"..v.p1.number.."\tp2[num]"..v.p2.number.."\t")
      v:calcDistToP(self.p)
   end
end

return LV
