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
      point:setVisible(0)
   end
end

function LV:addStartingPoints()
   for _,p in ipairs(self.points) do
      --check if the staring points are on both sides of the initial line
      if p.x > self.p.x and p.other.x > self.p.x and 
         p.y < self.p.y and p.other.y > self.p.y then
         
         print(p,"Point added to initial status")
         self:addToStatus(p)
         p:setVisible(0)
      end
   end
end


function LV:checkCloser(point,test)
   if test == self.status.null then
      print("test is null")
      return false
   end

   if point ~= test:getKeyObject().line.p1 and point ~= test:getKeyObject().line.p2 then
      --create lines
      local l1 = {}
      l1.x,l1.y = test:getKeyObject().line.p1.x,test:getKeyObject().line.p1.y
      l1.x2,l1.y2 = test:getKeyObject().line.p2.x,test:getKeyObject().line.p2.y
      table.insert(self.debugLines.t1, l1)

      local l2 = {} 
      l2.x,l2.y = self.p.x,self.p.y --our main point
      l2.x2,l2.y2 = point.x,point.y -- our current point
      table.insert(self.debugLines.t2, l2)

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
   
   return false
end

function LV:runAlg()
   for _,point in ipairs(self.points) do
      
      if not point.node then
         point.node = self.status:insert(point,point)
      end

      --iterate all possible node below current point
      local found = self:checkCloser(point,self.status.root)

      if not found then
         point:setVisible(1)
      else
         point:setVisible(0)
      end
      if point.node and point.other.node then
         local n = self.status:getMin()
         --[[if point.node == n or point.other.node == n then
            point:setVisible(1)
         end]]
         self.status:deleteNode(point.node)
         self.status:deleteNode(point.other.node)
         point.node = nil
         point.other.node = nil
      end

      --[[
      local min = self.status:getMin()
      if min ~= self.status.null then
         if not min:getKeyObject():isVisible() then

            if self:checkCloser(min:getKeyObject(),self.status.root) then
               min:getKeyObject():setVisible(1)
            end
         end
      end
      ]]

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
end

return LV
