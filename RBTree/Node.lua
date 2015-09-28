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
      print("is1 doesn't intersect sweepline")
      return false 
   end
   local is = Geo.intersection(sl,l2)
   if not is then 
      print("is1 doesn't intersect sweepline")
      return false 
   end
   --print(is1.x,is1.y,is.x,is.y)
   if LV:distToP(is1) < LV:distToP(is) then
      return true
   else
      return false
   end 

end

function Node:getValue()
   return self.obj
end

return Node
