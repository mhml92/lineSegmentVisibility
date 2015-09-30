local LV = Class("LV")

local RBTree = require 'RBTree/RBTree'
local Node = require 'RBTree/Node'
local Point = require 'entities/Point'
local Line = require 'entities/Line'

I = require("inspect")

function LV:initialize(points,lines,p,scene,co)
   self.scene = scene
   self.p = p
   self.points = points
   self.lines = lines
   self.status = RBTree:new()
   self.coroutine = co

   self.debugLines = {red={},yellow={}}
   --add distance for each point
   for _,p in ipairs(self.points) do
      --also reset nodes
      p:setValue(Vector.dist(self.p.x,self.p.y,p.x,p.y))
      p.line.node = nil
   end

   table.sort(self.points, function(p1,p2)
      local v1 = Vector.angleTo(self.p.x-p1.x,self.p.y-p1.y)
      local v2 = Vector.angleTo(self.p.x-p2.x,self.p.y-p2.y)

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
      --skip if line is already in the view
      if p.line.node then
         goto continue
      end
      --check if the staring points are on both sides of the initial line
      if (p.x >= self.p.x or p.other.x >= self.p.x) and 
         p.y <= self.p.y and p.other.y > self.p.y then

         --standard gym math         
         local a = (p.y-p.other.y)/(p.x-p.other.x)
         local b = p.y-a*p.x

         --now check if line intersects our P point's horizontal line i.e. y+P.y = 0
         local xintersect = (-b+self.p.y)/a-self.p.x


         --if x intersects the self.p.x axis or if the slope is infinite
         if xintersect >= 0 or p.x-p.other.x == 0  then

            local l = p.line
            l.node = self.status:insert(l,l)
            --swap points
            l:swapPoints()
         end
      end

      ::continue::
   end
end


function LV:checkPointClosest(point,test)
   --current test line
   local tl = test:getKeyObject()
   if point.line ~= tl then
      --create lines
      local l1 = {} --the closest line
      l1.x,l1.y = tl.p1.x,tl.p1.y 
      l1.x2,l1.y2 = tl.p2.x,tl.p2.y

      local l2 = {}
      l2.x,l2.y = self.p.x,self.p.y --our main point
      l2.x2,l2.y2 = point.x,point.y -- our current point

      if self:lineIntersection(l1,l2) then
         table.insert(self.debugLines.red, l2)
         return true
      end
   end
   --add yellow line
   local l = {}
   l.x,l.y = self.p.x,self.p.y --our main point
   l.x2,l.y2 = point.x,point.y -- our current point
   table.insert(self.debugLines.yellow, l)

   return false
end

function LV:runAlg()
   for _,point in ipairs(self.points) do
      local l = point.line
      --if point is the first of the two points in the line
      if point:isFirst() then
         l.node = self.status:insert(l,l)
      end

      local closest = self.status:getMin():getKeyObject()
      --only used for illustration purpose
      if closest == point.line then
         table.insert(self.debugLines.yellow, {x=self.p.x,y=self.p.y,x2=point.x,y2=point.y})
      else
         table.insert(self.debugLines.red, {x=self.p.x,y=self.p.y,x2=point.x,y2=point.y})
      end
      closest:getFirst():setVisible(1)

      --if point is the second in order
      if not point:isFirst() then
         self.status:deleteNode(l.node)
      end

      local closest = self.status:getMin():getKeyObject()
      if closest ~= nil then
         closest:getFirst():setVisible(1)
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
   love.graphics.setLineWidth(0.25)
   for _,l in pairs(self.debugLines.yellow) do
      love.graphics.setColor(YELLOW)
      love.graphics.line(l.x,l.y,l.x2,l.y2)
   end
   for _,l in pairs(self.debugLines.red) do
      love.graphics.setColor(DARKRED)
      love.graphics.line(l.x,l.y,l.x2,l.y2)
   end
end

return LV
