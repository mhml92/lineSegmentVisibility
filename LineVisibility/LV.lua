local LV = Class("LV")

local RBTree = require 'RBTree/RBTree'
local Node = require 'RBTree/Node'
local Point = require 'entities/Point'
local Line = require 'entities/Line'

function LV:initialize(points,lines,p,scene)
   self.scene = scene
   self.p = p
   self.points = points
   self.lines = lines
   self.status = RBTree:new()
   self.sweepLine = Line:new(Point:new(self.p.x,self.p.y,self.scene),Point:new(1000,self.p.y,self.scene),self.scene) 

   local p1,p2 = self.sweepLine.p1,self.sweepLine.p2
   local vx,vy = p2.x-p1.x,p2.y,p1.y
   print(vx,vy)
   print(Vector.angleTo(vx,vy))

   table.sort(self.points, function(p1,p2)
      local v1,v2 = Vector.angleTo(p.x,p.y,self.p1.x,self.p1.y), Vector.angleTo(p.x,p.y,self.p2.x,self.p2.y)
      if v1 < v2 then
         return true
      elseif v1 == v2 then
         local d1,d2 = Vector.dist2(self.p.x,self.p.y,v1.x,v1.y),Vector.dist2(self.p.x,self.p.y,v2.x,v2.y) 
         if d1 < d2 then 
            return true 
         else 
            return false 
         end
      else
         return false
      end
   end)
end

function LV:draw()
   self.sweepLine:draw()
end

return LV
