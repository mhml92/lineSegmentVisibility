local Geo = require "Geometry"
local Node = Class('Node')

function Node:initialize(color,obj,left,right,p)
   self.color = color
   self.obj = obj
   self.valueObject = valueObject
   self.left = left or self
   self.right = right or self
   self.p = p or self
end


function Node:isLessThan(n)
   local LV = n.obj.scene.LV

   local l1 = self.obj
   local l2 = n.obj
   
   local sl = LV:getSweepLine()
   -- intersection point of 'this' and sweepline
   local is1 = Geo.intersection(sl,self.obj)
   if not is1 then 
  --    print("is1 doesn't intersect sweepline")
    --  print(sl.p1,sl.p2,self.obj.p1,self.obj.p2, "test this")
      return false 
   end
   local is = Geo.intersection(sl,l2)
   if not is then 
--      print("is1 doesn't intersect sweepline")
      return false 
   end
   local d1,d2 = LV:distToP(is1),LV:distToP(is)
   if d1 < d2 then
      return true
   elseif d1 > d2 then
      return false
   else
     --[[ 
      local l1vx = l1.p2.x-l1.p1.x
      local l1vy = l1.p2.y-l1.p1.y

      local l2vx = l2.p2.x-l2.p1.x
      local l2vy = l2.p2.y-l2.p1.y

      if (l1vx == 0 and l1vy == 0) or (l2vx == 0 and l2vy == 0) then
         print("lel")
         return false 
      end

      l1vx,l1vy = Vector.normalize(l1vx,l2vy)
      l2vx,l2vy = Vector.normalize(l2vx,l2vy)
      slx,sly = Vector.normalize(sl.p1.x-l1vx,sl.p1.y-l1vy)
      if Vector.angleTo(l1vx,l1vy,slx,sly) < Vector.angleTo(l2vx,l2vy,slx,sly) then
         return true
      else 
         return false
      end
      ]]
      if l1.p1.x == l2.p1.x and l1.p1.y == l2.p1.y then
         return Geo.isLeftOf(l2,l1.p2)
      elseif l1.p2.x == l2.p2.x and l1.p2.y == l2.p2.y then 
         return Geo.isLeftOf(l2,l1.p1)
      else
         if l1.p1.x == is1.x and l1.p1.y == is.y then
            return true
         else 
            return false
         end
      end
   end 

end

function Node:getValue()
   return self.obj
end

return Node
